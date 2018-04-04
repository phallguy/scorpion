require "i18n"

I18n.load_path += Dir[ File.expand_path( "../scorpion/locale/*.yml", __FILE__ ) ]

module Scorpion

  require "scorpion/version"
  require "scorpion/error"
  require "scorpion/method"
  require "scorpion/object"
  require "scorpion/attribute_set"
  require "scorpion/hunter"
  require "scorpion/chain_hunter"
  require "scorpion/dependency_map"
  require "scorpion/hunt"
  require "scorpion/dependency"
  require "scorpion/nest"
  require "scorpion/stinger"
  require "scorpion/rails"

  # Hunts for an object that satisfies the requested `contract`.
  #
  # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
  # @return [Object] an object that satisfies the contract.
  # @raise [UnsuccessfulHunt] if a matching object cannot be found.
  def fetch( contract, *arguments, &block )
    hunt = Hunt.new( self, contract, *arguments, &block )
    execute hunt
  end

  # Creates a new object and feeds it it's dependencies.
  # @param [Class] object_class a class that includes {Scorpion::Object}.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  # @return [Scorpion::Object] the spawned object.
  def spawn( hunt, object_class, *arguments, &block )
    if object_class < Scorpion::Object
      object_class.spawn hunt, *arguments, &block
    else
      object_class.new *arguments, &block
    end
  end

  # Inject the {#target} with all non-lazy dependencies.
  # @param [Scorpion::Object] target to inject.
  # @return [target]
  def inject( target )
    hunt = Scorpion::Hunt.new self, nil
    hunt.inject target

    target
  end

  # Explicitly spawn an instance of {#object_class} and inject it's dependencies.
  # @param [Array<Object>] args to pass to the constructor.
  # @param [#call] block to pass to the constructor.
  # @return [Scorpion::Object] the spawned object.
  def new( object_class, *arguments, &block )
    hunt = Hunt.new( self, object_class, *arguments, &block )
    Scorpion::Dependency::ClassDependency.new( object_class ).fetch( hunt )
  end

  # Execute the `hunt` returning the desired dependency.
  # @param [Hunt] hunt to execute.
  # @return [Object] an object that satisfies the hunt contract.
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

  # @!attribute instance
  # @return [Scorpion] main scorpion for the app.
  def self.instance
    @instance_referenced = true
    @instance
  end
  @instance = Scorpion::Hunter.new
  @instance_referenced = false

  def self.instance=( scorpion )
    if @instance_referenced
      logger.warn "Replacing the global Scorpion.instance will not update any Scorpion::Nest instances created with the original scorpion." if warn_global_replace # rubocop:disable Metrics/LineLength
      @instance_referenced = false
    end
    @instance = scorpion
  end

  cattr_accessor :warn_global_replace
  self.warn_global_replace = true

  # Prepare the {#instance} for hunting.
  # @param [Boolean] reset true to free all existing resource and initialize a
  #   new scorpion.
  def self.prepare( reset = false, &block )
    @instance.reset if reset
    instance.prepare &block
  end

  # Hunt for dependency from the primary Scorpion {#instance}.
  # @see #fetch
  def self.fetch( dependencies, &block )
    instance.fetch dependencies, &block
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
    def unsuccessful_hunt( contract )
      fail UnsuccessfulHunt, contract
    end

end
