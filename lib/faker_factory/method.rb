require "faker_factory/method/faker"
require "faker_factory/method/control"

module FakerFactory
  class Method
    # TODO: problem with parsing "test()" => method = test; arguments = ["()"]
    METHOD_MATCHER = /((?<klass>[a-z_.:]+)\.)?(?<method>[a-z0-9_=\?]+)\s*(\((?<args1>.+)\)|(?<args2>.+))?\s*/i
    LEFT_BRACKET_MATCHER = /^\(/
    RIGHT_BRACKET_MATCHER = /\)$/
    # TODO: better argument splitting
    # does not works with arrays, hash etc method(1, [1, 2])
    ARGUMENT_SPLIT_MATCHER = /\s*,\s*/

    attr_reader :raw, :klass, :method, :arguments

    def initialize raw
      @raw = raw
      @klass, @method, @arguments = parse(@raw)
    end

    def source
      make_call(klass, method, arguments)
    end

    def call
      eval(source)
    end

    def to_s
      source
    end

    private

    def parse raw
      match     = resolve(raw)
      klass     = resolve_klass(match["klass"])
      method    = resolve_method(klass, match["method"])
      arguments = resolve_arguments(klass, method, match["args1"] || match["args2"])

      return [klass, method, arguments]
    end

    # Resolvers
    def resolve raw
      match = raw.match(METHOD_MATCHER)
      raise_custom NoMethodError, "missing method" unless match
      match
    end

    def resolve_klass klass_string
      if klass = parse_klass(klass_string)
        begin
          eval(klass)
        rescue NameError
          raise_custom NameError, "'#{klass}' is not valid class"
        rescue
        end

        klass
      end
    end

    def resolve_method klass, method_string
      raise_custom NoMethodError, "missing method" unless method_string

      method = parse_method(klass, method_string)
      call = make_call(klass, method)

      begin
        eval(call)
      rescue NameError, NoMethodError
        raise_custom NoMethodError, "'#{call}' is not valid method"
      rescue
      end

      method_string
    end

    def resolve_arguments klass, method, arguments_string
      arguments = parse_arguments(klass, method, arguments_string)
      call = make_call(klass, method, arguments)

      begin
        eval(call)
      rescue ArgumentError
        raise_custom ArgumentError, "'#{call}' has #{ex.message}"
      rescue
      end

      arguments
    end

    # Parsers
    def parse_klass klass_string
      return nil unless klass_string
      parts = klass_string.split("::").map {|s| s.split(".")}.flatten
      "::#{parts.map {|s| camelize(s)}.join("::")}"
    end

    def parse_method klass, method_string
      # TODO make some validations
      method_string
    end

    def parse_arguments klass, method, arguments_string
      if arguments_string
        arguments_string.
          strip.
          gsub(LEFT_BRACKET_MATCHER, '').
          gsub(RIGHT_BRACKET_MATCHER, '').
          split(ARGUMENT_SPLIT_MATCHER)
      else
        []
      end
    end

    # Helpers
    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end

    def raise_custom error, reason
      raise error, "FakerFactory: can't parse '#{raw}'. Reason: #{reason}."
    end

    def make_call klass, method, arguments = []
      call = klass ? "#{klass}.#{method}" : method
      "#{call}(#{arguments.join(", ")})"
    end
  end
end
