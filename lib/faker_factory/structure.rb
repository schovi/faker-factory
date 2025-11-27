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
        when Repeat then build_repeat(element)
        when Maybe then build_maybe(element)
        when Fake then build_fake(element)
        when Hash then build_hash(element)
        when Array then { type: :array, items: element.map { |e| build_executable(e) } }
        when String then build_string(element)
        else { type: :literal, value: element }
        end
      end

      def build_repeat(element)
        { type: :repeat, count: element.count, inner: build_executable(element.template) }
      end

      def build_maybe(element)
        { type: :maybe, probability: element.probability, inner: build_executable(element.template) }
      end

      def build_fake(element)
        { type: :fake, klass: element.klass, method_name: element.method_name, arguments: element.arguments }
      end

      def build_hash(element)
        { type: :hash, pairs: element.map { |k, v| { key: k.to_s, value: build_executable(v) } } }
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
        when :repeat then execute_repeat(node)
        when :maybe then execute_maybe(node)
        when :fake then execute_fake(node)
        when :hash then node[:pairs].each_with_object({}) { |p, h| h[p[:key]] = execute_node(p[:value]) }
        when :array then node[:items].map { |item| execute_node(item) }
        when :interpolated then node[:parts].map { |p| execute_node(p).to_s }.join
        end
      end

      def execute_repeat(node)
        count = node[:count]
        count = rand(count) if count.is_a?(Range)
        count.times.map { execute_node(node[:inner]) }
      end

      def execute_maybe(node)
        probability = node[:probability]
        if rand(1..100) <= probability
          execute_node(node[:inner])
        end
      end

      def execute_fake(node)
        klass = Allowlist.resolve_class(node[:klass])
        Allowlist.validate_method!(node[:method_name])

        args = node[:arguments]
        if args.is_a?(Hash)
          klass.public_send(node[:method_name], **args)
        elsif args.is_a?(Array) && args.any?
          klass.public_send(node[:method_name], *args)
        else
          klass.public_send(node[:method_name])
        end
      end

      def node_to_string(node, indent = "")
        case node[:type]
        when :literal then node[:value].inspect
        when :faker then node[:method].to_s
        when :repeat then repeat_to_string(node, indent)
        when :maybe then maybe_to_string(node, indent)
        when :fake then fake_to_string(node)
        when :hash then "{\n" + node[:pairs].map { |p| "#{indent}  #{p[:key].inspect} => #{node_to_string(p[:value], indent + "  ")}" }.join(",\n") + "\n#{indent}}"
        when :array then "[\n" + node[:items].map { |i| "#{indent}  #{node_to_string(i, indent + "  ")}" }.join(",\n") + "\n#{indent}]"
        when :interpolated then "\"" + node[:parts].map { |p| p[:type] == :faker ? "\#{#{p[:method]}}" : p[:value] }.join + "\""
        end
      end

      def repeat_to_string(node, indent)
        count_str = node[:count].is_a?(Range) ? "rand(#{node[:count]})" : node[:count]
        "FakerFactory::Method::Control.repeat(#{count_str}) do\n#{indent}  #{node_to_string(node[:inner], indent + "  ")}\n#{indent}end"
      end

      def maybe_to_string(node, indent)
        "FakerFactory::Method::Control.maybe(#{node[:probability]}) do\n#{indent}  #{node_to_string(node[:inner], indent + "  ")}\n#{indent}end"
      end

      def fake_to_string(node)
        args = node[:arguments]
        args_str = if args.is_a?(Hash) && args.any?
          "(#{args.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')})"
        elsif args.is_a?(Array) && args.any?
          "(#{args.map(&:inspect).join(', ')})"
        else
          ""
        end
        "#{node[:klass]}.#{node[:method_name]}#{args_str}"
      end
    end
  end
end
