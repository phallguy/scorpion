require 'scorpion/prey'

module Scorpion
  class Prey
    class CapturedPrey < Scorpion::Prey
      extend Forwardable

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [Object] the instance that was captured.
        attr_reader :instance

      # @!attribute
      # @return [Scorpion::Prey] the actual prey to hunt. Used to fetch the
      #   single {#instance}.
        attr_reader :specific_prey
        private :specific_prey


      delegate [:contract,:traits,:satisfies?] => :specific_prey

      #
      # @!endgroup Attributes

      def initialize( specific_prey )
        @specific_prey = specific_prey
      end

      # @see Prey#fetch
      def fetch( scorpion, *args, &block )
        @instance ||= specific_prey.fetch( scorpion, *args, &block )
      end

      # @see Prey#release
      def release
        @instance = nil
      end

    end
  end
end