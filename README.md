# Scorpion

[![Gem Version](https://badge.fury.io/rb/scorpion-ioc.svg)](http://badge.fury.io/rb/scorpion-ioc)
[![Code Climate](https://codeclimate.com/github/phallguy/scorpion.png)](https://codeclimate.com/github/phallguy/scorpion)
[![Test Coverage](https://codeclimate.com/github/phallguy/scorpion/badges/coverage.svg)](https://codeclimate.com/github/phallguy/scorpion/coverage)
[![Inch CI](https://inch-ci.org/github/phallguy/scorpion.svg?branch=master)](https://inch-ci.org/github/phallguy/scorpion)
[![Circle CI](https://circleci.com/gh/phallguy/scorpion.svg?style=svg)](https://circleci.com/gh/phallguy/scorpion)

Add IoC to rails with minimal fuss and ceremony.

<!-- MarkdownTOC depth=4 -->

- [Dependency Injection](#dependency-injection)
  - [Why might you _Want_ a DI FRamework?](#why-might-you-_want_-a-di-framework)
    - [Using a Framework...like Scorpion](#using-a-frameworklike-scorpion)
- [Using Scorpion](#using-scorpion)
  - [Objects](#objects)
  - [Configuration](#configuration)
    - [Classes](#classes)
    - [Modules](#modules)
    - [Traits](#traits)
    - [Builders](#builders)
    - [Hunting Delegates](#hunting-delegates)
    - [Singletons](#singletons)
  - [Nests](#nests)
  - [Rails](#rails)
    - [ActionController](#actioncontroller)
    - [ActiveJob](#activejob)
    - [ActiveRecord](#activerecord)
- [Contributing](#contributing)
- [License](#license)

<!-- /MarkdownTOC -->

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

Most of these counter arguments focus on testing, and given how easy it is to
mock objects in Ruby, you don't really need a framework. If testing were the
only virtue they'd be spot on. Despite it's virtues DI doesn't come without it's
own problems. However for larger projects that you expect to be long-lived, a DI
framework may help manage the complexity.

For a deeper background on Dependency Injection consider the
[Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection) article on the
subject.

### Why might you _Want_ a DI FRamework?

Assuming you've embraced the general concept of DI why would you want to use a
framework. Lets consider the alternatives.

##### Setter/Default Injection

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

- Still coupled to a specific type of Weapon.
- If multiple classes use this approach and you decide to upgrade your armory,
  you'd have to modify every line that creates new weapons. The factory pattern
  can be used to address  such a dependency.
- No global method of replacing a Weapon class with a specialized or augmented
  class. For example a ThreadLockedWeapon.

##### Constructor/Ignorant Injection

```ruby
class Hunter
  def initialize( weapon )
    @weapon = weapon
  end
end
```

Here Hunters can use any weapon and can be designed to an interface Weapon that
does not have an implementation yet.

**PROS**

- Provides flexibility
- Work can proceed concurrently on Hunter and Weapon classes by different
  engineers  on the team.

**CONS**

- Hard to reason about Hunters and Weapons as a whole.
- The dependency is not clearly defined - what is a weapon?
- It pushes the responsibility of constructing dependencies onto the consumer of
  the class. If the class is used in multiple places this becomes a maintenance
  chore when changes are required.
- It becomes tedious to use classes resulting in repeated boilerplate code that
  distracts from the primary responsibility of the calling code.


#### Using a Framework...like Scorpion

Using a good framework can help conserve the pros of each method while
minimizing the cons. A DI framework works like an automatic factory system
resolving dependencies cleanly like a factory but without all the effort to
create custom factories.

A good framework should

- Make dependencies clear
- Require a minimal amount of configuration or ceremony

```ruby
class Hunter
  depend_on do
    weapon Weapon
  end
end
```

Here the dependency is clearly defined - and even creates accessors for getting
and setting the weapon. When a Hunter is created it's dependencies are also
created - and any of their dependencies and so on. Usage is equally simple

```ruby
hunter = scorpion.fetch Hunter
hunter.weapon   # => a Weapon
```

Overriding the kind of weapons used by hunters.

```ruby
class Axe < Weapon; end

scorpion.prepare do
  hunt_for Axe
end

hunter = scorpion.fetch Hunter
hunter.weapon # => an Axe
```

Overriding hunters!

```ruby
  class Axe < Weapon; end
  class Predator < Hunter; end

  scorpion.prepare do
    hunt_for Predator
    hunt_for Axe
  end

  hunter = scorpion.fetch Hunter
  hunter        # => Predator
  hunter.weapon # => an Axe
```


## Using Scorpion

Out of the box Scorpion does not need any configuration and will work
immediately. You can hunt for any Class even if it hasn't been configured.

```ruby
  hash = Scorpion.instance.fetch Hash
  hash # => {}
```

### Objects

Scorpions feed their [Scorpion Objects](lib/scorpion/object.rb) - any object that
should be fed its dependencies when it is created. Simply include the
Scorpion::Object module into your class to benefit from Scorpion injections.

```ruby
class Keeper
  include Scorpion::Object

  depend_on do
    lunch FastFood
  end
end

class Zoo
  include Scorpion::Object

  depend_on do # or #depend_on if you like
    keeper Zoo::Keeper
    vet Zoo::Vet, lazy: true
  end
end

zoo = scorpion.fetch Zoo
zoo.keeper       # => an instance of a Zoo::Keeper
zoo.vet?         # => false it hasn't been hunted down yet
zoo.vet          # => an instnace of a Zoo::Vet
zoo.keeper.lunch # => an instance of FastFood
```

All of your classes should be objects! And any dependency that is also a Object will
be fed.

### Configuration

A good scorpion should be prepared to hunt. An effort that describes what the
scorpion hunts for and how it should be found. Scorpion uses Classes and Modules
as the primary means of identifying dependency in favor of opaque labels or strings.
This serves two benefits:

1. The type of object expected by the dependency is clearly identified making it
   easier to understand what the concrete dependencies really are.
2. Types (Classes & Modules) explicitly declare the expected behavioral contract
   of an object's dependencies.

#### Classes

Most scorpion hunts will be for an instance of a specific class (or a more
derived class). In the absence of any configuration, Scorpion will simply create
an instance of the specific class requested.

```ruby
scorpion.fetch Hash   # => Hash.new

scorpion.prepare do
  hunt_for Object::HashWithIndifferentAccess
end

scorpion.fetch Hash   # => Object::HashWithIndifferentAccess.new
```

#### Modules

Modules can be hunted for in two ways.

1. If a Class has been prepared for hunting that includes the module, it will
   be used to satisfy requests for that module
2. If no Class is found, the Module itself will be returned.

```ruby
module Sharp
  module_function
  def poke; self.class.name end
end

class Sword
  include Sharp
end

poker = scorpion.fetch Sharp
poker.poke     # => "Module"

scorpion.prepare do
  hunt_for Sword
end

poker = scorpion.fetch Sharp
poker.poke     # => "Sword"
```

#### Traits

Traits can be used to distinguish between dependency of the same type. For example
a scorpion may be prepare to hunt for several weapons and the object needs a
blunt weapon.

```ruby
class Weapon; end
class Mace < Weapon; end
class Hammer < Weapon; end
class Sword < Weapon; end

scorpion.prepare do
  hunt_for Hammer, :blunt
  hunt_for Sword, :sharp
  hunt_for Mace, :blunt, :sharp
end

scorpion.fetch Weapon, :blunt # => Hammer.new
scorpion.fetch Weapon, :sharp # => Sword.new
scorpion.fetch Weapon, :sharp, :blunt # => Mace.new
```

Modules can also be used to identify specific traits desired from the hunted
dependency.

```ruby
module Color; end
module Streaming; end
class Logger; end
class Console < Logger
  include Color
end
class SysLog < Logger
  include Streaming
end

scorpion.prepare do
  hunt_for Console
  hunt_for SysLog
end

scorpion.fetch Logger, Color      # => Console.new
scorpion.fetch Logger, Streaming  # => SysLog.new
```

#### Builders

Sometimes resolving the correct dependencies is a bit more dynamic. In those
cases you can use a builder block to hunt for dependency.

```ruby
class Samurai < Sword; end
class Broad < Sword; end

scorpion.prepare do
  hunt_for Sword do |scorpion|
    scorpion.spawn Random.rand( 2 ) == 1 ? Samurai : Broad
  end
end
```

Objects may also define their own .create methods that receive a scorpion and
arguments.

```ruby
class City
  def self.create( scorpion, name )
    klass = if name == "New York"
      BigCity
    else
      SmallCity
    end

    klass.new name
  end

  def initialize( name )
    @name = name
  end
end

class BigCity < City; end
class SmallCity < City; end

```

#### Hunting Delegates

For really complex dependencies you may want to delegate the effort to retrieve
the dependencies to another type - a factory module for example. Scorpion
allows you to delegate hunting dependency using the `:with` option.

```ruby
module ChocolateFactory
    module_function

    def call( scorpion, *args, &block )
      case args.first
      when Nuget        then scorpion.spawn Snickers, *args, &block
      when Butterscotch then scorpion.spawn Butterfinger, *args, &block
      when Coconut      then scorpion.spawn Garbage, *args, &block
      end
    end
end

scorpion.prepare do
  hunt_for Candy, with: ChocolateFactory
end

scorpion.fetch Candy, Nuget.new  #=> Snickers.new Nugget.new
```

Any object that responds to `#call( scorpion, *args, &block )` can be used as
a hunting delegate.

#### Singletons

Scorpion allows you to capture dependency and feed the same instance to everyone that
asks for a matching dependency.

DI singletons are different then global singletons in that each scorpion can
have a unique instance of the class that it shares with all of it's objects. This
allows, for example, global variable like support per-request without polluting
the global namespace or dealing with thread concurrency issues.


```ruby
class Logger; end

scorpion.prepare do
  capture Logger
end

scorpion.fetch Logger  # => Logger.new
scorpion.fetch Logger  # => Previously captured logger
```

Captured dependencies are not shared with child scorpions (for example when
conceiving scorpions from a [Nest](Nests)). To share captured dependency with children
use `share`.

### Nests

A scorpion nest is where a mother scorpion lives and conceives young -
duplicates of the mother but maintaining their own state. The scorpion nest is
used by the Rails integration to give each request it's own scorpion.

All preparation  performed by the mother is shared with all the children it
conceives so that configuration is established when the application starts.

```ruby
nest.prepare do
  hunt_for Logger
end

scorpion = nest.conceive
scorpion.fetch Logger  # => Logger.new
```

### Rails

#### ActionController

Scorpion provides simple integration into for rails controllers to establish
a scorpion for each request.

```ruby
# user_service.rb
class UserService
  def find( username ) ... end
end

# config/nest.rb
require 'scorpion'

Scorpion.prepare do
  capture UserService  # Share with all the objects that are spawned in _this_ request

  share do
    capture Logger  # Share with every request
  end
end

# application_controller.rb
require 'scorpion'

class ApplicationController < ActionController::Base
  depend_on do
    users UserService, lazy: true
  end
end

# users_controller.rb
class UsersController < ApplicationController
  def show
    user = users.find( "batman" )
    logger.write "Found a user: #{ user }"
  end
end
```

#### ActiveJob

Simliar to support for controllers, Scorpion provides support for dependency
injection into ActiveJob objects.

```ruby

# avatar_job.rb
class AvatarJob < ActiveJob::Base
  def perform( id )
    user = users.find( id )
    logger.write "Found a user: #{ user }"
  end
end
```

#### ActiveRecord

Scorpion enhances ActiveRecord models to support resolving dependencies from
a scorpion and sharing that scorpion with all associations.

```ruby
class User < ActiveRecord::Base
  depend_on do
    credentials Service::Auth::Credentials
  end

  def check_password( password )
    credentials.check encoded_password, password
  end
end

class SessionsController < ActionController::Base

  def create
    user = User.with_scorpion( scorpion ).find params[:id]
    sign_in if user.check_password( params[:password] )
  end
end
```


## Contributing

1. Fork it ( https://github.com/phallguy/scorpion/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## License

[The MIT License (MIT)](http://opensource.org/licenses/MIT)

Copyright (c) 2015 Paul Alexander