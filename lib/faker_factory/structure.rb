module FakerFactory
  class Structure
    FAKER_MATCHER = /\%{(?<content>.*?)\}/

    class << self
      def object_to_lambda(object)
        executable = build_executable(object)
        -> { execute_node(executable) }
      end

      def object_to_source(object)
        executable = build_executable(object)
        "lambda do\n  #{node_to_string(executable)}\nend"
      end

      private

      def build_executable(element)
        case element
        when Hash then build_hash(element)
        when Array then { type: :array, items: element.map { |e| build_executable(e) } }
        when String then build_string(element)
        else { type: :literal, value: element }
        end
      end

      def build_hash(element)
        keys = element.keys

        if keys.length == 1 && (match = keys.first.to_s.match(FAKER_MATCHER))
          { type: :control, method: Method::Control.new(match["content"]), inner: build_executable(element[keys.first]) }
        else
          { type: :hash, pairs: element.map { |k, v| { key: k.to_s, value: build_executable(v) } } }
        end
      end

      def build_string(source)
        parts = partition_string(source)

        return parts.first if parts.length == 1
        { type: :interpolated, parts: parts }
      end

      def partition_string(string)
        result = []

        loop do
          text, placeholder, string = string.partition(FAKER_MATCHER)
          result << { type: :literal, value: text } unless text.empty?

          if placeholder.length > 0
            match = placeholder.match(FAKER_MATCHER)
            result << { type: :faker, method: Method::Faker.new(match[1]) }
          end

          break if string.empty?
        end

        result
      end

      def execute_node(node)
        case node[:type]
        when :literal then node[:value]
        when :faker then node[:method].execute
        when :control then node[:method].execute { execute_node(node[:inner]) }
        when :hash then node[:pairs].each_with_object({}) { |p, h| h[p[:key]] = execute_node(p[:value]) }
        when :array then node[:items].map { |item| execute_node(item) }
        when :interpolated then node[:parts].map { |p| execute_node(p).to_s }.join
        end
      end

      def node_to_string(node, indent = "")
        case node[:type]
        when :literal then node[:value].inspect
        when :faker then node[:method].to_s
        when :control then "#{node[:method]} do\n#{indent}  #{node_to_string(node[:inner], indent + "  ")}\n#{indent}end"
        when :hash then "{\n" + node[:pairs].map { |p| "#{indent}  #{p[:key].inspect} => #{node_to_string(p[:value], indent + "  ")}" }.join(",\n") + "\n#{indent}}"
        when :array then "[\n" + node[:items].map { |i| "#{indent}  #{node_to_string(i, indent + "  ")}" }.join(",\n") + "\n#{indent}]"
        when :interpolated then "\"" + node[:parts].map { |p| p[:type] == :faker ? "\#{#{p[:method]}}" : p[:value] }.join + "\""
        end
      end
    end
  end
end
