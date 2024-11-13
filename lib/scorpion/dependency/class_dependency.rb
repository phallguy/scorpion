require "scorpion/dependency"

module Scorpion
  class Dependency
    # {Dependency} for a {Class} contract
    class ClassDependency < Scorpion::Dependency
      def fetch(hunt)
        hunt.scorpion.spawn(hunt, contract, *hunt.arguments, &hunt.block)
      end
    end
  end
end
