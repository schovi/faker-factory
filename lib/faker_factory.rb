require "faker"
require "faker_factory/version"
require "faker_factory/allowlist"
require "faker_factory/safe_argument_parser"
require "faker_factory/method"
require "faker_factory/repeat"
require "faker_factory/maybe"
require "faker_factory/fake"
require "faker_factory/structure"
require "faker/preset"

# Required - sometimes Faker throws error on missing locale
I18n.reload!

module FakerFactory
  class << self
    def locale=(locale)
      Faker::Config.locale = locale
    end

    def once(object)
      generator(object).call
    end

    def generator(object)
      Structure.object_to_lambda(object)
    end

    def debug(object)
      Structure.object_to_source(object)
    end

    def repeat(count, template = nil, &block)
      Repeat.new(count, template, &block)
    end

    def maybe(probability = 50, template = nil, &block)
      Maybe.new(probability, template, &block)
    end

    def fake(klass_or_string, method_name = nil, **kwargs)
      Fake.new(klass_or_string, method_name, **kwargs)
    end
  end
end
