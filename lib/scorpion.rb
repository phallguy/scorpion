module Scorpion
  require 'scorpion/version'
  require 'scorpion/rails'
  require 'scorpion/king'
  require 'scorpion/attribute_set'
  require 'scorpion/scorpions'

  # Hunts for an object that matches the template defined in the attribute.
  # @param [Scorpion::Attribute] attribute to hunt for.
  # @param [Object] object that will be fed the hunted attribute.
  # @return [Object] an object that matches the requirements defined in `attribute` or nil.
  # @raise UnsuccessfulHunt if a matching object cannot be found.
  def hunt!( attribute, object = nil )
    fail "Not implemented"
  end

  # Hunts for an object and returns nil if the hunt is unssuccessful.
  # @see #hunt!
  def hunt( attribute, object = nil )
    hunt! attribute, object
  rescue UnsuccessfulHunt
  end

  # Populate given `king` with its expected attributes.
  # @param [Scorpion::King] king to be fed.
  # @return [Scorpion::King] the populated king.
  def feed!( king )
    king.injected_attributes.each do |attr|
      king.send :feed, attr, hunt!( attr, king )
    end
  end

  # Creates a new king and feeds it it's dependencies.
  # @param [Scorpion::King] king_class a class that includes {Scorpion::King}.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  def spawn( king_class, *args, &block )
    if king_class < Scorpion::King
      king_class.spawn self, *args, &block
    else
      king_class.new *args, &block
    end
  end


  private

    def unsuccessful_hunt!( attribute )
      fail UnsuccessfulHunt, "Couldn't find a builder for #{ attribute.contract } with traits: #{ attribute.traits }"
    end

end
