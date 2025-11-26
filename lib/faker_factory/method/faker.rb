module FakerFactory
  class Method
    class Faker < FakerFactory::Method
      private

      def raise_error(error_class, reason)
        raise error_class, "FakerFactory: can't parse '#{@raw}'. Reason: #{reason}. See: https://github.com/faker-ruby/faker"
      end

      def normalize_class_name(klass_string)
        raise_error(NameError, "missing faker class") unless klass_string

        # If starts with ::, it's an explicit global reference - don't prepend Faker::
        return klass_string[2..] if klass_string.start_with?("::")

        class_name = super(klass_string)
        class_name.match?(/\AFaker/i) ? class_name : "Faker::#{class_name}"
      end
    end
  end
end
