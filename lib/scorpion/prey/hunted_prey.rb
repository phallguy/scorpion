require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} for a contract that implements #hunt
    class HuntedPrey < Scorpion::Prey

      # @see Scorpion::Prey#fetch
      def fetch( scorpion, *args, &block )
        contract.hunt( scorpion, *args, &block )
      end
    end
  end
end