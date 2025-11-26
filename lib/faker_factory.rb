require "faker"
require "faker_factory/version"
require "faker_factory/allowlist"
require "faker_factory/safe_argument_parser"
require "faker_factory/structure"
require "faker_factory/method"
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
  end
end
