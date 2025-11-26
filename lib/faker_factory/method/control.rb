module FakerFactory
  class Method
    class Control < FakerFactory::Method
      class << self
        def repeat(count, params = {}, &block)
          count = rand(count) if count.is_a?(Range)
          result = count.times.map { yield }
          result.empty? && params[:nil] ? nil : result
        end

        def maybe(probability = 50, &block)
          raise ArgumentError, "Probability must be between 1 and 99" unless (1..99).cover?(probability)
          yield if rand(1..100) <= probability
        end
      end

      def initialize(raw)
        @raw = raw
        parse_control!
      end

      def execute(&block)
        Allowlist.validate_method!(@method_name)
        self.class.public_send(@method_name, *@arguments, &block)
      end

      def to_s
        args_str = @arguments.empty? ? "" : "(#{@arguments.map(&:inspect).join(', ')})"
        "FakerFactory::Method::Control.#{@method_name}#{args_str}"
      end

      private

      def parse_control!
        match = @raw.match(METHOD_MATCHER)
        raise_error(NoMethodError, "missing method") unless match

        @method_name = match["method"]
        @klass = self.class
        @arguments = SafeArgumentParser.parse(match["args"])
      end

      def raise_error(error_class, reason)
        raise error_class, "FakerFactory: can't parse '#{@raw}'. Reason: #{reason}."
      end
    end
  end
end
