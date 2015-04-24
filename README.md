
# Cirru::Parser

Cirru Parser in Ruby

## Develop

```
ruby test.rb
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cirru-parser'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install cirru-parser
```

## Usage

```ruby
require 'cirru/parser'

Cirru::Parser.parse 'code', 'filename'
# => returns tree

Cirru::Parser.pare 'code', 'filename'
# => returns simplified tree
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cirru-parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
