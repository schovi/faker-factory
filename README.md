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

With simple schema generates fake data. Supports structure controling like how many items array should have or value presence based on probability. For random data is used (Faker gem)[https://github.com/stympy/faker].

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
    id: "%{number.number(5)}",
    name: "%{name.name}",
    email: "%{internet.email}"
  }
)

=> {"id"=>"70095", "name"=>"Mr. Alverta Gibson", "email"=>"seamus@schambergerswaniawski.name"}
```

### Repeating

#### Generated Array with given number of items

Use hash with only one special control key `"%{repeat(n)}"`

```ruby
FakerFactory.once(
  {"%{repeat(2)}" => "I have email %{internet.email}"}
)
=> ["I have email eryn@bayer.name", "I have email roxane.hoppe@rosenbaum.com"]
```

#### Generated Array with random number of items

From empty Array to Array with N items with `repeat(0..n)`

```ruby
3.times do
  p FakerFactory.once({"%{repeat(0..2)}" => "My favorite beer is: %{beer.name}"})
end

=> ["My favorite beer is Pliny The Elder", "My favorite beer is: Brooklyn Black"]
=> ["My favorite beer is: Ten FIDY"]
=> []
```

#### Generated Array with random number of items and nothing for empty array

For empty Array returns `nil` with `repeat(0..n, nil: true)`

```ruby
FakerFactory.once({"%{repeat(0..1, nil: true)}" => "My favorite beer is: %{beer.name}"})
=> nil
```

### Value presence with probability

Use hash with only one special control key `"%{maybe}"` - change is 50%. `maybe(20)` - chance is 20%

```ruby
2.times do
  FakerFactory.once({"%{maybe(20)}" => "I like to watch on movies with %{superhero.name}"})
end
=> "I like to watch on movies with Giant Thanos Thirteen"
=> nil
```

### Complex example

```ruby
FakerFactory.once(
  {
    id:       "%{number.number(5)}",
    name:     "%{name.name}",
    age:      20,
    facebook: "%{internet.url('facebook.com/profile')}",
    friends: {
      "%{maybe(75)}" => {
        "%{repeat(2..20)}" => {
          id:       "%{number.number(5)}",
          name:     "%{name.name}",
          facebook: "%{internet.url('facebook.com/profile')}",
        }
      }
    }
  }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests, or `guard` to run . You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec faker-factory` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schovi/faker-factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
