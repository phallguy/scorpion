require "scorpion/dependency"

module Scorpion
  class Dependency
    class CapturedDependency < Scorpion::Dependency
      extend Forwardable

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [Object] the instance that was captured.
        attr_reader :instance

      # @!attribute
      # @return [Scorpion::Dependency] the actual dependency to hunt. Used to fetch the
      #   single {#instance}.
        attr_reader :specific_dependency
        private :specific_dependency


      delegate [ :contract, :satisfies? ] => :specific_dependency

      #
      # @!endgroup Attributes

      def initialize( specific_dependency )
        @specific_dependency = specific_dependency
      end

      # @see Dependency#fetch
      def fetch( hunt )
        @instance ||= specific_dependency.fetch( hunt ) # rubocop:disable Naming/MemoizedInstanceVariableName
      end

      # @see Dependency#release
      def release
        @instance = nil
      end

      # @see Dependency#replicate
      def replicate
        dup.tap(&:release)
      end

    end
  end
end
