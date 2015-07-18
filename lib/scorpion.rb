require 'i18n'

I18n.load_path += Dir[ File.expand_path( '../scorpion/locale/*.yml', __FILE__ ) ]

module Scorpion
  require 'scorpion/version'
  require 'scorpion/error'
  require 'scorpion/king'
  require 'scorpion/attribute_set'
  require 'scorpion/hunter'
  require 'scorpion/hunting_map'
  require 'scorpion/prey'
  require 'scorpion/stinger'
  require 'scorpion/nest'
  require 'scorpion/rails'

  # @return [Scorpion] main scorpion for the app.
  def self.instance
    @instance
  end
  @instance = Scorpion::Hunter.new

  # Prepare the {#instance} for hunting.
  def self.prepare( &block )
    instance.prepare &block
  end

  # Hunts for an object that satisfies the requested `contract` and `traits`.
  # @param [Class,Module,Symbol] contract describing the desired behavior of the prey.
  # @param [Array<Symbol>] traits required of the prey
  # @return [Object] an object that matches the requirements defined in `attribute`.
  # @raise [UnsuccessfulHunt] if a matching object cannot be found.
  def hunt_by_traits!( contract, traits, *args, &block )
    fail "Not implemented"
  end
  alias_method :fetch_by_traits!, :hunt_by_traits!

  # Hunts for an object that satisfies the requested `contract` regardless of
  # traits.
  # @see #hunt_by_traits!
  def hunt!( contract, *args, &block )
    hunt_by_traits!( contract, nil, *args, &block )
  end
  alias_method :fetch!, :hunt!

  # Populate given `king` with its expected attributes.
  # @param [Scorpion::King] king to be fed.
  # @return [Scorpion::King] the populated king.
  def feed!( king )
    king.injected_attributes.each do |attr|
      king.send :feed, attr, hunt_by_traits!( attr.contract, attr.traits )
    end
  end

  # Creates a new king and feeds it it's dependencies.
  # @param [Class] king_class a class that includes {Scorpion::King}.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  # @return [Scorpion::King] the spawned king.
  def spawn( king_class, *args, &block )
    if king_class < Scorpion::King
      king_class.spawn self, *args, &block
    else
      king_class.new *args, &block
    end
  end

  # Creates a new {Scorpion} copying the current configuration any any currently
  # captured prey.
  # @return [Scorpion] the replicated scorpion.
  def replicate( &block )
    fail "Not implemented"
  end

  # Free up any captured prey and release any long-held resources.
  def destroy
  end

  # @return [Scorpion::Nest] a nest that uses this scorpion as the mother.
  def build_nest
    Scorpion::Nest.new( self )
  end

  private

    # Used by concrete scorpions to notify the caller that the hunt was
    # unsuccessful.
    def unsuccessful_hunt!( contract, traits )
      fail UnsuccessfulHunt.new contract, traits
    end

end
