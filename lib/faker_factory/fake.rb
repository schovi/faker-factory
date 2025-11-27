module FakerFactory
  class Fake
    attr_reader :klass, :method_name, :arguments

    def initialize(klass_or_string, method_name = nil, **kwargs)
      if klass_or_string.is_a?(String)
        parse_string(klass_or_string)
      elsif klass_or_string.is_a?(Symbol)
        @klass = symbol_to_faker_class(klass_or_string)
        @method_name = method_name.to_s
        @arguments = kwargs
      else
        @klass = klass_or_string.to_s
        @method_name = method_name.to_s
        @arguments = kwargs
      end
    end

    private

    def symbol_to_faker_class(sym)
      class_name = sym.to_s.split("_").map(&:capitalize).join
      "Faker::#{class_name}"
    end

    def parse_string(str)
      match = str.match(Method::METHOD_MATCHER)
      raise ArgumentError, "Invalid faker string: #{str}" unless match

      @method_name = match["method"]
      klass_string = match["klass"]

      if klass_string
        @klass = normalize_class_name(klass_string)
      else
        raise ArgumentError, "Missing class in faker string: #{str}"
      end

      # Parse arguments from string - returns array of positional args
      parsed_args = SafeArgumentParser.parse(match["args"])
      # Convert to hash if it's a single hash, otherwise keep as array
      @arguments = if parsed_args.length == 1 && parsed_args.first.is_a?(Hash)
        parsed_args.first
      else
        parsed_args
      end
    end

    def normalize_class_name(klass_string)
      parts = klass_string.split("::").flat_map { |s| s.split(".") }
      normalized = parts.map { |s| s.split("_").map(&:capitalize).join }.join("::")

      if normalized.start_with?("::")
        normalized
      else
        "Faker::#{normalized}"
      end
    end
  end
end
