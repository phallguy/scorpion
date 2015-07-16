# Scorpion

[![Gem Version](https://badge.fury.io/rb/scorpion-ioc.svg)](http://badge.fury.io/rb/scorpion-ioc)
[![Code Climate](https://codeclimate.com/github/phallguy/scorpion.png)](https://codeclimate.com/github/phallguy/scorpion)
[![Test Coverage](https://codeclimate.com/github/phallguy/scorpion/badges/coverage.svg)](https://codeclimate.com/github/phallguy/scorpion/coverage)
[![Circle CI](https://circleci.com/gh/phallguy/scorpion.svg?style=svg)](https://circleci.com/gh/phallguy/scorpion)

Add IoC to rails with minimal fuss and ceremony.

Embrace convention over configuration while still benefitting from the
dependency injection design principle.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Dependency Injection](#dependency-injection)
- [Using Scorpion](#using-scorpion)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Dependency Injection

Dependency injection helps to break explicit dependencies between objects making
it much easier to maintain a [single
responsibility](https://en.wikipedia.org/wiki/Single_responsibility_principle)
and reduce [coupling](https://en.wikipedia.org/wiki/Coupling_(computer_programming))
in our class designs. This leads to more testable code and code that is more
resilient to change.

Several have argued that the dynamic properties of Ruby make Dependency
Injection _frameworks_ irrelevant. Some argue that you can build in defaults and
make them overridable, or just use module mixins.

Most of the counter arguments focus around testing, and with the easy of mocking
in Ruby, you don't really need a framework. If testing were the only virtue
they'd be spot on, and DI doesn't come without it's own problems. However for
larger projects that you expect to be long-lived, a DI framework can help manage
the complexity.

For a deeper background on Dependency Injection consider the
[Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection) article on the
subject.

### Why might you _Want_ a DI FRamework?

Assuming you've embraced the general concept of DI why would you want to use a
framework. Lets consider the alternatives.

#### Alternatives

##### Setter Injection

```ruby
class Hunter
    def weapon
      @weapon ||= Weapon.new
    end
    def weapon=( value )
      @weapon = value
    end
end
```

In this scenario the Hunter class knows how to create a weapon and provides a
sane default, but allows the dependency to be overridden if needed.

**PROS**

- Very simple to understand and debug
- Provides basic flexibility
- The dependency is clearly defined.

**CONS**

- Still coupled to a specific type of Weapon. If multiple classes use this
  approach and you decide to upgrade your armory, you'd have to modify each
  class to create new weapons.




## Using Scorpion

...


## Contributing

1. Fork it ( https://github.com/phallguy/scorpion/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


# License

The MIT License (MIT)

Copyright (c) 2015 Paul Alexander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.