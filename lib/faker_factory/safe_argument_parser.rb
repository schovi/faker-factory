module FakerFactory
  # Parses argument strings into Ruby literals safely (no eval)
  # Supports: strings, numbers, booleans, nil, symbols, ranges, arrays, hashes
  module SafeArgumentParser
    class << self
      def parse(argument_string)
        return [] if argument_string.nil? || argument_string.strip.empty?
        tokenize(argument_string.strip).map { |token| parse_token(token.strip) }
      end

      def parse_token(token)
        return nil if token.empty?

        case token
        when /\A'(.*)'\z/m then $1.gsub("\\'", "'")
        when /\A"(.*)"\z/m then $1.gsub('\\"', '"').gsub("\\n", "\n").gsub("\\t", "\t")
        when /\A-?\d+\z/ then token.to_i
        when /\A-?\d+\.\d+\z/ then token.to_f
        when /\A(-?\d+)\.\.(-?\d+)\z/ then Range.new($1.to_i, $2.to_i)
        when /\Atrue\z/i then true
        when /\Afalse\z/i then false
        when /\Anil\z/i then nil
        when /\A:([a-zA-Z_]\w*)\z/ then $1.to_sym
        when /\A\[.*\]\z/m then parse_array(token)
        when /\A\{.*\}\z/m then parse_hash(token)
        else
          raise SecurityError, "FakerFactory: Invalid argument '#{token}' - only literals allowed"
        end
      end

      private

      def tokenize(string)
        tokens = []
        current = ""
        depth = 0
        in_string = false
        string_char = nil

        string.each_char.with_index do |char, i|
          prev_char = i > 0 ? string[i - 1] : nil

          if (char == '"' || char == "'") && prev_char != '\\'
            if in_string && char == string_char
              in_string = false
              string_char = nil
            elsif !in_string
              in_string = true
              string_char = char
            end
          end

          unless in_string
            depth += 1 if char == "[" || char == "{"
            depth -= 1 if char == "]" || char == "}"

            if char == "," && depth == 0
              tokens << current.strip unless current.strip.empty?
              current = ""
              next
            end
          end

          current += char
        end

        tokens << current.strip unless current.strip.empty?
        tokens
      end

      def parse_array(token)
        inner = token[1..-2].strip
        return [] if inner.empty?
        tokenize(inner).map { |t| parse_token(t.strip) }
      end

      def parse_hash(token)
        inner = token[1..-2].strip
        return {} if inner.empty?

        result = {}
        tokenize(inner).each do |pair|
          if pair =~ /\A\s*([a-zA-Z_]\w*):\s*(.+)\z/
            result[$1.to_sym] = parse_token($2.strip)
          elsif pair.include?("=>")
            key, value = pair.split("=>", 2)
            result[parse_token(key.strip)] = parse_token(value.strip)
          else
            raise SecurityError, "FakerFactory: Invalid hash syntax '#{pair}'"
          end
        end
        result
      end
    end
  end
end
