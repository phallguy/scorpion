require 'scorpion/prey'

module Scorpion
  class Prey
    # {Prey} for a {Module} contract
    class ModulePrey < Scorpion::Prey

      def fetch( scorpion, *args, &block )
        contract
      end

    end
  end
end