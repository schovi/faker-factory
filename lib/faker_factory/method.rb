require "faker_factory/method/faker"
require "faker_factory/method/control"

module FakerFactory
  class Method
    METHOD_MATCHER = /((?<klass>[a-z_.:]+)\.)?(?<method>[a-z0-9_=\?]+)\s*(\((?<args>.*)\))?\s*/i

    attr_reader :raw, :klass, :method_name, :arguments

    def initialize(raw)
      @raw = raw
      parse!
    end

    def execute(block: nil)
      Allowlist.validate_method!(@method_name)

      if block
        @klass.public_send(@method_name, *@arguments, &block)
      else
        @klass.public_send(@method_name, *@arguments)
      end
    end

    def to_s
      class_name = @klass.is_a?(Module) ? Module.instance_method(:name).bind(@klass).call : @klass.to_s
      args_str = @arguments.empty? ? "" : "(#{@arguments.map(&:inspect).join(', ')})"
      "#{class_name}.#{@method_name}#{args_str}"
    end

    private

    def parse!
      match = @raw.match(METHOD_MATCHER)
      raise_error(NoMethodError, "missing method") unless match

      @method_name = match["method"]
      @klass = resolve_klass(match["klass"])
      @arguments = SafeArgumentParser.parse(match["args"])
    end

    def resolve_klass(klass_string)
      return nil unless klass_string
      class_name = normalize_class_name(klass_string)
      Allowlist.resolve_class(class_name)
    end

    def normalize_class_name(klass_string)
      parts = klass_string.split("::").flat_map { |s| s.split(".") }
      parts.map { |s| s.split("_").map(&:capitalize).join }.join("::")
    end

    def raise_error(error_class, reason)
      raise error_class, "FakerFactory: can't parse '#{@raw}'. Reason: #{reason}."
    end
  end
end
