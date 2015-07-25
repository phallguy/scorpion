require 'scorpion/dependency'

module Scorpion
  class Dependency
    # {Dependency} for an captured argument.
    # @see {Scorpion#argument}.
    class ArgumentDependency < Scorpion::Dependency

      attr_reader :argument

      def initialize( argument )
        @argument = argument
      end

      def fetch( *args )
        argument
      end

      def satisfies?( contract, traits = nil )
        contract === argument && traits.blank?
      end

    end
  end
end