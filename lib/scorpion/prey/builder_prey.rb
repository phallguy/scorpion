require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} that delegates to another object that implements
    # #call( scorpion, *args, &block ).
    class BuilderPrey < Scorpion::Prey

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [#call(scorpion,*args,&block)] the builder to use to fetch instances of the prey.
        attr_reader :builder

      #
      # @!endgroup Attributes

      def initialize( contract, traits = nil, builder = nil, &block )
        @builder = block_given? ? block : builder
        super contract, traits
      end

      # @see Scorpion::Prey#fetch
      def fetch( scorpion, *args, &block )
        builder.call( scorpion, *args, &block )
      end

    end
  end
end