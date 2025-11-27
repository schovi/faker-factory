require 'test_helper'

describe FakerFactory do
  it "generates static value" do
    assert_equal "static", FakerFactory.once("static")
  end

  it "generates faker name" do
    result = FakerFactory.once("Hello %{name.name}")
    assert result.start_with?("Hello ")
  end

  it "returns generator lambda" do
    generator = FakerFactory.generator("%{name.name}")
    results = 3.times.map { generator.call }
    assert_equal 3, results.length
    results.each { |r| assert r.is_a?(String) }
  end

  it "returns debug source" do
    result = FakerFactory.debug("%{name.name}")
    assert result.include?("Faker::Name.name")
  end

  it "handles arrays" do
    result = FakerFactory.once(["%{name.name}", "%{number.digit}"])
    assert_equal 2, result.length
  end

  it "handles hashes" do
    result = FakerFactory.once({
      string: "%{name.name}",
      number: "%{number.digit}",
      nested: { email: "%{internet.email}" }
    })
    assert result.key?("string")
    assert result.key?("nested")
    assert result["nested"].key?("email")
  end

  it "handles maybe control with block syntax" do
    results = 20.times.map { FakerFactory.once(FakerFactory.maybe { "value" }) }
    assert results.include?(nil) || results.include?("value")
  end

  it "handles maybe control with argument syntax" do
    results = 20.times.map { FakerFactory.once(FakerFactory.maybe(50, "value")) }
    assert results.include?(nil) || results.include?("value")
  end

  it "handles maybe with probability" do
    results = 20.times.map { FakerFactory.once(FakerFactory.maybe(90) { "value" }) }
    assert results.include?("value")
  end

  it "handles repeat control with block syntax" do
    result = FakerFactory.once(FakerFactory.repeat(3) { "item" })
    assert_equal ["item", "item", "item"], result
  end

  it "handles repeat control with argument syntax" do
    result = FakerFactory.once(FakerFactory.repeat(3, "item"))
    assert_equal ["item", "item", "item"], result
  end

  it "handles repeat with range" do
    result = FakerFactory.once(FakerFactory.repeat(2..5) { "item" })
    assert result.length >= 2 && result.length <= 5
  end

  it "handles nested controls" do
    result = FakerFactory.once(FakerFactory.maybe(99) { FakerFactory.repeat(2) { "nested" } })
    assert result.nil? || result == ["nested", "nested"]
  end

  it "preserves literal values" do
    result = FakerFactory.once({ age: 25, active: true, score: 3.14 })
    assert_equal 25, result["age"]
    assert_equal true, result["active"]
    assert_equal 3.14, result["score"]
  end
end

describe "Fake helper" do
  it "generates faker value with symbol API" do
    result = FakerFactory.once(FakerFactory.fake(:name, :name))
    assert result.is_a?(String)
    assert result.length > 0
  end

  it "generates faker value with string API" do
    result = FakerFactory.once(FakerFactory.fake("name.name"))
    assert result.is_a?(String)
    assert result.length > 0
  end

  it "generates faker value with arguments (symbol API)" do
    result = FakerFactory.once(FakerFactory.fake(:number, :number, digits: 5))
    assert result.is_a?(Integer)
    assert result.to_s.length == 5
  end

  it "generates faker value with arguments (string API)" do
    result = FakerFactory.once(FakerFactory.fake("number.number({digits: 5})"))
    assert result.is_a?(Integer)
    assert result.to_s.length == 5
  end

  it "works in nested structures" do
    result = FakerFactory.once({
      user: {
        name: FakerFactory.fake(:name, :name),
        email: FakerFactory.fake(:internet, :email)
      }
    })
    assert result["user"]["name"].is_a?(String)
    assert result["user"]["email"].include?("@")
  end

  it "works with repeat" do
    result = FakerFactory.once(FakerFactory.repeat(3) { FakerFactory.fake(:name, :first_name) })
    assert_equal 3, result.length
    result.each { |name| assert name.is_a?(String) }
  end

  it "works with maybe" do
    results = 20.times.map { FakerFactory.once(FakerFactory.maybe(50) { FakerFactory.fake(:name, :name) }) }
    non_nil = results.compact
    assert non_nil.length > 0
    non_nil.each { |name| assert name.is_a?(String) }
  end

  it "handles underscore class names" do
    result = FakerFactory.once(FakerFactory.fake(:ancient, :god))
    assert result.is_a?(String)
  end
end

describe "Security" do
  it "blocks eval" do
    assert_raises(SecurityError) { FakerFactory.once("%{::Kernel.eval('1')}") }
  end

  it "blocks system" do
    assert_raises(SecurityError) { FakerFactory.once("%{::Kernel.system('ls')}") }
  end

  it "blocks File" do
    assert_raises(SecurityError) { FakerFactory.once("%{::File.read('/etc/passwd')}") }
  end

  it "blocks IO" do
    assert_raises(SecurityError) { FakerFactory.once("%{::IO.read('/etc/passwd')}") }
  end

  it "blocks send method" do
    assert_raises(SecurityError) { FakerFactory.once("%{name.send('name')}") }
  end

  it "blocks instance_eval" do
    assert_raises(SecurityError) { FakerFactory.once("%{name.instance_eval('name')}") }
  end

  it "blocks code in arguments" do
    assert_raises(SecurityError) { FakerFactory.once("%{name.name(File.read('x'))}") }
  end

  it "allows Faker methods" do
    assert FakerFactory.once("%{name.name}").is_a?(String)
    assert FakerFactory.once("%{internet.email}").is_a?(String)
    assert FakerFactory.once("%{color.hex_color}").is_a?(String)
  end

  it "allows explicit global classes that are not blocked" do
    result = FakerFactory.once("%{::SecureRandom.uuid}")
    assert result.is_a?(String)
    assert_equal 36, result.length
  end
end
