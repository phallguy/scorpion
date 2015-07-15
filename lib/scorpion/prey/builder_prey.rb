require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} for an explicit builder block
    class BuilderPrey < Scorpion::Prey

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [#call(scorpion)] the builder to use to fetch instances of the prey.
        attr_reader :builder

      #
      # @!endgroup Attributes


      def initialize( contract, traits = nil, &builder )
        @builder = builder
        super
      end

      # @see Scorpion::Prey#fetch
      def fetch( scorpion, *args, &block )
        builder.call( scorpion, *args, &block )
      end

    end
  end
end