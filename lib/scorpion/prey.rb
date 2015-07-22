module Scorpion
  # Prey that can be fed to a {Scorpion::King} by a {Scorpion}.
  class Prey

    require 'scorpion/prey/captured_prey'
    require 'scorpion/prey/class_prey'
    require 'scorpion/prey/module_prey'
    require 'scorpion/prey/builder_prey'
    require 'scorpion/prey/hunted_prey'
    require 'scorpion/prey/argument_prey'

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Class,Module,Symbol] contract describing the desired behavior of the prey.
      attr_reader :contract

    # @!attribute
    # @return [Array<Symbol>] the traits available on the prey.
      attr_reader :traits

    #
    # @!endgroup Attributes

    def initialize( contract, traits = nil )
      @contract = contract
      @traits   = Set.new( Array( traits ) )
    end

    # @return [Boolean] if the prey satisfies the required contract and traits.
    def satisfies?( contract, traits = nil )
      satisfies_contract?( contract ) && satisfies_traits?( traits )
    end

    # Fetch an instance of the prey.
    # @param [Scorpion] scorpion hunting for the prey.
    # @param [Array<Object>] arguments to the consructor of the prey.
    # @param [#call] block to pass to constructor.
    # @return [Object] the hunted prey.
    def fetch( scorpion, *args, &block )
      fail "Not Implemented"
    end

    # Release the prey, freeing up any long held resources.
    def release
    end

    # Replicate the Prey.
    # @return [Prey] a replication of the prey.
    def replicate
      dup
    end

    def ==( other )
      return unless other
      self.class == other.class &&
      contract   == other.contract &&
      traits     == other.traits
    end
    alias_method :eql?, :==

    def hash
      self.class.hash ^
      contract.hash ^
      traits.hash
    end

    private

      # @return [Boolean] true if the pray satisfies the given contract.
      def satisfies_contract?( contract )
        if self.contract.is_a? Symbol
          self.contract == contract
        else
          self.contract <= contract
        end
      end

      # @return [Boolean] true if the pray satisfies the given contract.
      def satisfies_traits?( traits )
        return true if traits.blank?

        Array( traits ).all? do |trait|
          case trait
          when Symbol then self.traits.include? trait
          when Module then self.contract <= trait
          else fail ArgumentError, "Unsupported trait"
          end
        end
      end

  end
end