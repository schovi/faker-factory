module FakerFactory
  class Method
    class Control < FakerFactory::Method
      attr_reader :call_block

      class << self
        def repeat(count, params = {}, &block)
          if count.is_a?(Range)
            count = rand(count)
          end

          result = count.times.map do
            yield
          end

          result.length == 0 && params[:nil] ? nil : result
        end

        def maybe probability = 50, &block
          if probability <= 0
            raise "Probability must be greater than 0%"
          elsif probability >= 100
            raise "Probability must be lesser than 100%"
          end

          yield if rand(0..100) <= probability
        end
      end

      def initialize raw, block_content = nil, &block
        super(raw)

        @call_block = if block_given?
          "#{block.call}"
        elsif block_content
          raise "Block does not implements .call" unless block_content.respond_to?(:call)

          "#{block_content}"
        else
          raise "Block is not provided"
        end
      end

      def source
        "#{super} do #{@call_block} end" if @call_block
      end

      private

      def raise_custom error, reason
        raise error, "FakerFactory: can't parse '#{raw}'. Reason: #{reason}. For usage see: https://github.com/stympy/faker"
      end

      def parse_klass klass_string
        raise_custom NameError, "'#{klass_string}' can't be presented" if klass_string
        "::FakerFactory::Method::Control"
      end
    end
  end
end
