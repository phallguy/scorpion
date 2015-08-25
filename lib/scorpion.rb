require 'i18n'

I18n.load_path += Dir[ File.expand_path( '../scorpion/locale/*.yml', __FILE__ ) ]

module Scorpion

  require 'scorpion/version'
  require 'scorpion/error'
  require 'scorpion/method'
  require 'scorpion/object'
  require 'scorpion/object_constructor'
  require 'scorpion/attribute_set'
  require 'scorpion/hunter'
  require 'scorpion/chain_hunter'
  require 'scorpion/dependency_map'
  require 'scorpion/hunt'
  require 'scorpion/dependency'
  require 'scorpion/nest'
  require 'scorpion/stinger'
  require 'scorpion/rails'

  # Hunts for an object that satisfies the requested `contract` and `traits`.
  # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
  # @param [Array<Symbol>] traits required of the dependency
  # @param [Hash<Symbol,Object>] dependencies to inject into the object.
  # @return [Object] an object that satisfies the contract and traits.
  # @raise [UnsuccessfulHunt] if a matching object cannot be found.
  def fetch_by_traits( contract, traits, *arguments, **dependencies, &block )
    hunt = Hunt.new( self, contract, traits, *arguments, **dependencies, &block )
    execute hunt
  end

  # Hunts for an object that satisfies the requested `contract` regardless of
  # traits.
  # @see #fetch_by_traits
  def fetch( contract, *arguments, **dependencies, &block )
    fetch_by_traits( contract, nil, *arguments, **dependencies, &block )
  end

  # Creates a new object and feeds it it's dependencies.
  # @param [Class] object_class a class that includes {Scorpion::Object}.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  # @return [Scorpion::Object] the spawned object.
  def spawn( hunt, object_class, *arguments, **dependencies, &block )
    if object_class < Scorpion::Object
      object_class.spawn hunt, *arguments, **dependencies, &block
    else
      object_class.new *arguments, &block
    end
  end

  # Explicitly spawn an instance of {#object_class} and inject it's dependencies.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  # @return [Scorpion::Object] the spawned object.
  def new( object_class, *arguments, **dependencies, &block )
    hunt = Hunt.new( self, object_class, nil, *arguments, **dependencies, &block )
    Scorpion::Dependency::ClassDependency.new( object_class ).fetch( hunt )
  end

  # Execute the `hunt` returning the desired dependency.
  # @param [Hunt] hunt to execute.
  # @return [Object] an object that satisfies the hunt contract and traits.
  def execute( hunt )
    fail "Not implemented"
  end

  # Creates a new {Scorpion} copying the current configuration any any currently
  # captured dependency.
  # @return [Scorpion] the replicated scorpion.
  def replicate( &block )
    fail "Not implemented"
  end

  # Free up any captured dependency and release any long-held resources.
  def destroy
    reset
  end

  # Reset the hunting map and clear all dependencies.
  def reset
  end

  # @return [Scorpion::Nest] a nest that uses this scorpion as the mother.
  def build_nest
    Scorpion::Nest.new( self )
  end

  # @!attribute
  # @return [Logger] logger for the scorpion to use.
  def logger
    @logger || Scorpion.logger
  end
  def logger=( value )
    @logger = value
  end

  # ============================================================================
  # @!group Convenience Methods
  #
  # Module methods to make it easier to work with scorpion configurations. These
  # _should not_ be used by library level classes. Instead only application
  # level code (controllers, scripts, etc.) should explicitly access these
  # methods.

  # @return [Scorpion] main scorpion for the app.
  def self.instance
    @instance
  end
  @instance = Scorpion::Hunter.new

  # Prepare the {#instance} for hunting.
  # @param [Boolean] reset true to free all existing resource and initialize a
  #   new scorpion.
  def self.prepare( reset = false, &block )
    if reset
      @instance.destroy
      @instance = Scorpion::Hunter.new
    end
    instance.prepare &block
  end

  # Hunt for dependency from the primary Scorpion {#instance}.
  # @see #fetch
  def self.fetch( dependencies, &block )
    instance.fetch dependencies, &block
  end

  # Hunt for dependency from the primary Scorpion {#instance}.
  # @see #fetch_by_traits
  def self.fetch_by_traits( dependencies, &block )
    instance.fetch_by_traits dependencies, &block
  end

  # @!attribute logger
  # @return [Logger] logger for the Scorpion framework to use.
  def self.logger
    @logger ||= defined?( ::Rails ) ? ::Rails.logger : Logger.new( STDOUT )
  end
  def self.logger=( value )
    @logger = value
  end

  #
  # @!endgroup Convenience Methods


  private

    # Used by concrete scorpions to notify the caller that the hunt was
    # unsuccessful.
    def unsuccessful_hunt( contract, traits )
      fail UnsuccessfulHunt.new contract, traits
    end

end
