module FakerFactory
  # Simple security layer - block dangerous methods, allow everything else
  # The real security comes from:
  # 1. Using const_get + public_send instead of eval
  # 2. Parsing arguments as literals (no Ruby expressions)
  # 3. Blocking a small set of truly dangerous methods
  module Allowlist
    # Methods that could execute arbitrary code or access system resources
    BLOCKED_METHODS = %w[
      eval instance_eval class_eval module_eval
      exec system spawn fork `
      send __send__ public_send
      method method_missing
      require require_relative load autoload
      open
      const_get const_set remove_const
      define_method remove_method undef_method
      instance_variable_get instance_variable_set remove_instance_variable
      binding
    ].freeze

    # Classes that provide dangerous system access
    BLOCKED_CLASSES = %w[
      Kernel
      IO File Dir FileUtils Pathname
      Process Signal
      Socket TCPSocket UDPSocket UNIXSocket
      Open3 PTY
    ].freeze

    class << self
      def blocked_method?(method_name)
        BLOCKED_METHODS.include?(method_name.to_s)
      end

      def blocked_class?(class_name)
        normalized = class_name.to_s.sub(/^::/, "")
        BLOCKED_CLASSES.any? do |blocked|
          normalized == blocked || normalized.start_with?("#{blocked}::")
        end
      end

      def validate_class!(class_name)
        if blocked_class?(class_name)
          raise SecurityError, "FakerFactory: Class '#{class_name}' is not allowed"
        end
      end

      def validate_method!(method_name)
        if blocked_method?(method_name)
          raise SecurityError, "FakerFactory: Method '#{method_name}' is not allowed"
        end
      end

      # Safely resolve a class constant
      def resolve_class(class_name)
        normalized = class_name.to_s.sub(/^::/, "")
        validate_class!(normalized)

        normalized.split("::").reduce(::Object) do |mod, const|
          mod.const_get(const, false)
        end
      rescue NameError
        raise NameError, "FakerFactory: Class '#{class_name}' does not exist"
      end
    end
  end
end
