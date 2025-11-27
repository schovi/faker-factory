[![Build Status](https://travis-ci.org/schovi/FakerFactory.png?branch=master)](https://travis-ci.org/schovi/FakerFactory)
[![Gem Version](https://badge.fury.io/rb/faker-factory.png)](http://badge.fury.io/rb/faker-factory)
[![Coverage Status](https://coveralls.io/repos/schovi/FakerFactory/badge.png)](https://coveralls.io/r/schovi/FakerFactory)

# FakerFactory

Fake data generator for simple and complex structures or objects. For data generation it uses [Faker gem](https://github.com/stympy/faker)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faker-factory'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install faker-factory
```

## Usage

With simple schema generates fake data. Supports structure controlling like how many items array should have or value presence based on probability. For random data is used [Faker gem](https://github.com/stympy/faker).

### String

All following rows are equivalent.

```ruby
FakerFactory.once("Hello, my name is %{Faker::Name.name}")
=> "Hello, my name is Miss Darius Stokes"
FakerFactory.once("Hello, my name is %{Name.name}")
=> "Hello, my name is Ms. Santino Gutmann"
FakerFactory.once("Hello, my name is %{name.name}")
=> "Hello, my name is Miss Edward Kunde"
```

### Array

#### Simple array with content

```ruby
FakerFactory.once(
  [
    "I live in %{address.city}",
    "My family came from %{address.country}"
  ]
)
=> ["I live in Winnifredshire", "And my family came from Hungary"]
```

### Hash

```ruby
FakerFactory.once(
  {
    id: "%{number.number({digits: 5})}",
    name: "%{name.name}",
    email: "%{internet.email}"
  }
)

=> {"id"=>"70095", "name"=>"Mr. Alverta Gibson", "email"=>"seamus@schambergerswaniawski.name"}
```

### Faker Value Shorthand

Use `FakerFactory.fake` for direct faker values without string interpolation:

```ruby
# Symbol API (recommended)
FakerFactory.once(FakerFactory.fake(:name, :name))
=> "Prof. Clement Ferry"

FakerFactory.once(FakerFactory.fake(:internet, :email))
=> "john@example.com"

# With arguments
FakerFactory.once(FakerFactory.fake(:number, :number, digits: 5))
=> 80159

# String API (same as %{...} syntax)
FakerFactory.once(FakerFactory.fake("name.name"))
=> "Dr. Jane Smith"
```

### Repeating

Use `FakerFactory.repeat` to generate arrays with repeated content.

#### Block syntax

```ruby
FakerFactory.once(FakerFactory.repeat(3) { "I have email %{internet.email}" })
=> ["I have email eryn@bayer.name", "I have email roxane@rosenbaum.com", "I have email john@doe.test"]
```

#### Argument syntax

```ruby
FakerFactory.once(FakerFactory.repeat(2, "Hello"))
=> ["Hello", "Hello"]
```

#### Random number of items with range

```ruby
3.times do
  p FakerFactory.once(FakerFactory.repeat(0..2) { "My favorite beer is: %{beer.name}" })
end

=> ["My favorite beer is Pliny The Elder", "My favorite beer is: Brooklyn Black"]
=> ["My favorite beer is: Ten FIDY"]
=> []
```

### Value presence with probability

Use `FakerFactory.maybe` to conditionally include values based on probability.

#### Block syntax (default 50% probability)

```ruby
FakerFactory.once(FakerFactory.maybe { "I like movies with %{superhero.name}" })
=> "I like movies with Giant Thanos Thirteen"  # or nil
```

#### With custom probability

```ruby
FakerFactory.once(FakerFactory.maybe(20) { "Rare value!" })
=> "Rare value!"  # 20% chance, otherwise nil
```

#### Argument syntax

```ruby
FakerFactory.once(FakerFactory.maybe(75, "I appear 75% of the time"))
=> "I appear 75% of the time"  # or nil
```

### Complex example

```ruby
FakerFactory.once(
  {
    id: FakerFactory.fake(:number, :number, digits: 5),
    name: FakerFactory.fake(:name, :name),
    age: 20,
    facebook: "%{internet.url('facebook.com/profile')}",
    friends: FakerFactory.maybe(75) {
      FakerFactory.repeat(2..20) {
        {
          id: FakerFactory.fake(:number, :number, digits: 5),
          name: FakerFactory.fake(:name, :name),
          facebook: "%{internet.url('facebook.com/profile')}"
        }
      }
    }
  }
)
```

### Reusable Generator

Create a reusable generator that produces different data on each call:

```ruby
gen = FakerFactory.generator(FakerFactory.repeat(3) { FakerFactory.fake(:name, :name) })
gen.call  # => ["Alice Smith", "Bob Jones", "Carol White"]
gen.call  # => ["Dave Brown", "Eve Green", "Frank Black"]
```

### Debug

See the compiled lambda source code:

```ruby
FakerFactory.debug(FakerFactory.repeat(2) { FakerFactory.fake(:name, :first_name) })
=> "lambda do
  FakerFactory::Method::Control.repeat(2) do
    Faker::Name.first_name
  end
end"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests, or `guard` to run . You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec faker-factory` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schovi/faker-factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
