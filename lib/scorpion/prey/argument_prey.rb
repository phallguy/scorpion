require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} for an captured argument.
    # @see {Scorpion#argument}.
    class ArgumentPrey < Scorpion::Prey

      attr_reader :argument

      def initialize( argument )
        @argument = argument
      end

      def fetch( scorpion, *args, &block )
        argument
      end

      def satisfies?( contract, traits = nil )
        contract === argument && traits.blank?
      end

    end
  end
end