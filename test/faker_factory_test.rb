require 'test_helper'

describe FakerFactory do
  before do
    # Faker::Name.stub :name do
    #   "John Doe"
    # end
    #
    # Faker::Number.stub :number, 4 do
    #   1234
    # end
    #
    # Faker::Color.stub :hex_color do
    #   "#123456"
    # end
    #
    # Faker::Email.stub :email do
    #   "john@doe.com"
    # end
    #
    # Faker::Email.stub :email, "jane" do
    #   "jane@doe.com"
    # end
  end

  it "test_static_value" do
    FakerFactory.once("static")
  end

  it "test_faker_name" do
    FakerFactory.once("aaa %{name.name}")
  end

  it "test_concatenate_faker_with_text" do
    FakerFactory.once("name: %{name.name}")
  end

  it "test_generator" do
    generator = FakerFactory.generator("%{name.name}")

    10.times do
      generator.call
    end
  end

  it "test_debug" do
    FakerFactory.debug("%{name.name}")
  end

  it "test_array" do
    FakerFactory.once(["%{name.name}", "%{number.number(4)}"])
  end

  it "test_hash" do
    FakerFactory.once({
      string: "%{name.name}",
      number: "%{number.number(4)}",
      another_hash: {
        hex_color: "%{color.hex_color}",
        array_with_hash: [
          {
            email: "%{internet.email}"
          },
          {
            email: "%{internet.email('jane')}"
          }
        ]
      }
    })
  end

  it "test_maybe" do
    FakerFactory.once({"%{maybe}": "%{name.name}"})
  end

  it "test_maybe_with_probability" do
    FakerFactory.once({"%{maybe(10)}": "%{name.name}"})
  end

  it "test_repeat" do
    FakerFactory.once({"%{repeat(2)}": "%{name.name}"})
  end

  it "test_repeat_with_random_count" do
    FakerFactory.once({"%{repeat(1..10)}": "%{name.name}"})
  end

  it "test_maybe_with_repeat" do
    FakerFactory.once({
      "%{maybe}": {
        "%{repeat(2)}": "%{name.name}"
      }
    })
  end

  # TODO
  # it "test_native_method" do
  #   FakerFactory.once("%{rand}")
  # end
end
