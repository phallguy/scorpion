require "scorpion/dependency"

module Scorpion
  class Dependency
    # {Dependency} for a {Module} contract
    class ModuleDependency < Scorpion::Dependency
      def fetch(*_args)
        contract
      end
    end
  end
end