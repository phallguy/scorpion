module Scorpion
  # {#chart} available {Prey} and {#find} them based on desired
  # {#{Scorpion::Attribute attributes}.
  class HuntingMap
    include Enumerable
    extend Forwardable

    # ============================================================================
    # @!group Attributes
    #

    # @return [Scorpion] the scorpion that created the map.
      attr_reader :scorpion

    # @return [Set] the set of prey charted on this map.
      attr_reader :prey_set
      private :prey_set

    # @return [Set] the set of prey charted on this map that is shared with all
    #   child prey.
      attr_reader :shared_prey_set
      private :shared_prey_set


    # @return [Set] the active prey set either {#prey_set} or {#shared_prey_set}
      attr_reader :active_prey_set
      private :active_prey_set

    #
    # @!endgroup Attributes

    def initialize( scorpion )
      @scorpion = scorpion
      @prey_set = @active_prey_set = []
      @shared_prey_set = []
    end

    # Find {Prey} that matches the requested `contract` and `traits`.
    # @param [Class,Module,Symbol] contract describing the desired behavior of the prey.
    # @param [Array<Symbol>] traits found on the {Prey}.
    # @return [Prey] the prey matching the attribute.
    def find( contract, traits = nil )
      prey_set.find{ |p| p.satisfies?( contract, traits ) } ||
      shared_prey_set.find{ |p| p.satisfies?( contract, traits ) }
    end

    # Chart the {Prey} that this hunting map can {#find}.
    def chart( &block )
      return unless block_given?

      if block.arity == 1
        yield self
      else
        instance_eval &block
      end

      self
    end

    # Define {Prey} that can be found on this map by `contract` and `traits`.
    #
    # If a block is given, it will be used build the actual instances of the
    # prey for the {Scorpion}.
    #
    # @param [Class,Module,Symbol] contract describing the desired behavior of the prey.
    # @param [Array<Symbol>] traits found on the {Prey}.
    # @return [Scorpion::Prey] the prey to be hunted for.
    def hunt_for( contract, traits = nil, &builder )
      active_prey_set.unshift prey_class( contract, &builder ).new( contract, traits, &builder )
    end
    alias_method :offer, :hunt_for

    # Captures a single prey and returns the same instance fore each request
    # for the resource.
    # @see #hunt_for
    def capture( contract, traits = nil, &builder )
      active_prey_set.unshift Scorpion::Prey::CapturedPrey.new( prey_class( contract, &builder ).new( contract, traits, &builder ) )
    end
    alias_method :singleton, :capture

    # Share captured prey defined within the block with all child scorpions.
    def share( &block )
      old_set = active_prey_set
      @active_prey_set = shared_prey_set
      yield
    ensure
      @active_prey_set = old_set
    end

    def each( &block )
      prey_set.each &block
    end
    delegate [ :empty?, :blank?, :present? ] => :prey_set

    # Replicates the prey in `other_map` into this map.
    # @param [Scorpion::HuntingMap] other_map to replicate from.
    def replicate_from( other_map )
      other_map.each do |prey|
        if replica = prey.replicate
          prey_set << replica
        end
      end
    end

    private
      def prey_class( contract, &builder )
        return Scorpion::Prey::BuilderPrey if block_given?
        return Scorpion::Prey::HuntedPrey  if contract.respond_to? :hunt
        return Scorpion::Prey::ClassPrey   if contract.is_a? Class
        return Scorpion::Prey::ClassPrey   if contract.is_a? Module

        raise Scorpion::BuilderRequiredError
      end
  end
end