# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Library Purpose

FakerFactory is a Ruby gem that generates fake data for complex structures (strings, arrays, hashes). It wraps the Faker gem with a DSL that supports:
- String interpolation with Faker methods: `%{name.name}`, `%{internet.email}`
- Control structures: `%{repeat(n)}` for arrays, `%{maybe(probability)}` for conditional values
- Nested data structures with combined control and data generation

## Development Commands

### Testing
```bash
# Run all tests
rake test
# or just
rake

# Run tests with Guard (auto-rerun on file changes)
guard
```

### Interactive Console
```bash
bin/console
```

### Installation
```bash
# Install gem locally
bundle exec rake install

# Release new version (update version.rb first)
bundle exec rake release
```

## Architecture

### Core Components

**FakerFactory module** (`lib/faker_factory.rb`)
- Entry point with three main methods:
  - `FakerFactory.once(object)` - Generate data once from a template
  - `FakerFactory.generator(object)` - Return a reusable lambda generator
  - `FakerFactory.debug(object)` - Show generated lambda source code

**Structure class** (`lib/faker_factory/structure.rb`)
- Converts template objects (Hash/Array/String) into executable lambda source code
- Pattern: `object → source code → lambda → execution`
- Key regex: `FAKER_MATCHER = /\%{(?<content>.*?)}/` matches interpolation placeholders
- Recursively processes nested structures via `build_faker_element`

**Method classes** (`lib/faker_factory/method/`)
- Base class `Method` parses method calls from strings like `"name.name"` or `"number.number(10)"`
- `Method::Faker` - Handles Faker gem method calls, auto-prepends `::Faker` namespace
- `Method::Control` - Implements control structures (`repeat`, `maybe`) as class methods

**Faker::Preset** (`lib/faker/preset.rb`)
- Optional preset templates for common data formats (e.g., Apache logs)

### Data Flow

1. User provides template (String/Hash/Array with `%{...}` placeholders)
2. `Structure.object_to_source` recursively builds lambda source code
3. Strings with `%{method.call}` → parsed by `Method::Faker` → converted to `Faker::Method.call`
4. Hashes with `%{repeat(n)}` or `%{maybe}` → parsed by `Method::Control` → wrapped in control flow
5. Source code evaluated to create lambda
6. Lambda called to generate random data

### Key Patterns

**Template syntax:**
- `%{name.name}` → Auto-resolves to `Faker::Name.name`
- `%{Faker::Internet.email}` → Explicit Faker class reference
- `{"%{repeat(5)}" => template}` → Generate array with 5 items
- `{"%{maybe(75)}" => template}` → 75% chance to include value

**Code generation:**
- All templates compile to Ruby lambda source code via string concatenation
- Uses `eval()` to convert source strings to executable lambdas
- Control structures use block syntax: `repeat(n) do ... end`
