require 'scorpion/dependency'

module Scorpion
  class Dependency
    # {Dependency} that delegates to another object that implements
    # #call( scorpion, *args, &block ).
    class BuilderDependency < Scorpion::Dependency

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [#call(scorpion,*args,&block)] the builder to use to fetch instances of the dependency.
        attr_reader :builder

      #
      # @!endgroup Attributes

      def initialize( contract, traits = nil, builder = nil, &block )
        @builder = block_given? ? block : builder
        super contract, traits
      end

      # @see Scorpion::Dependency#fetch
      def fetch( hunt )
        builder.call( hunt, *hunt.arguments, &hunt.block )
      end

    end
  end
end