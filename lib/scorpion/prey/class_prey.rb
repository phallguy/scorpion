require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} for a {Class} contract
    class ClassPrey < Scorpion::Prey

      def fetch( scorpion, *args, &block )
        scorpion.spawn contract, *args, &block
      end
    end
  end
end