require "scorpion/dependency"

module Scorpion
  class Dependency
    # {Dependency} for an captured argument.
    # @see {Scorpion#argument}.
    class ArgumentDependency < Scorpion::Dependency
      attr_reader :argument

      def initialize(argument)
        @argument = argument
      end

      def fetch(*_args)
        argument
      end

      def satisfies?(contract)
        contract === argument
      end
    end
  end
end
