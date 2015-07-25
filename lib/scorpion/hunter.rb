module Scorpion
  # A concrete implementation of a Scorpion used to hunt down food for a {Scorpion::Object}.
  # @see Scorpion
  class Hunter
    include Scorpion

    # ============================================================================
    # @!group Attributes
    #

    # @return [Scorpion::DependencyMap] map of {Dependency} and how to create instances.
      attr_reader :dependency_map
      protected :dependency_map

    # @return [Scorpion] parent scorpion to deferr hunting to on missing dependency.
      attr_reader :parent
      private :parent

    #
    # @!endgroup Attributes

    def initialize( parent = nil, &block )
      @parent      = parent
      @dependency_map = Scorpion::DependencyMap.new( self )

      prepare &block if block_given?
    end

    # Prepare the scorpion for hunting.
    # @see DependencyMap#chart
    def prepare( &block )
      dependency_map.chart &block
    end

    # @see Scorpion#replicate
    def replicate
      replica = self.class.new self
      replica.dependency_map.replicate_from( dependency_map )
      replica
    end

    # @see Scorpion#hunt
    def execute( hunt )
      dependency   = dependency_map.find( hunt.contract, hunt.traits )
      dependency ||= parent.dependency_map.find( hunt.contract, hunt.traits ) if parent
      dependency ||= Dependency.define( hunt.contract ) if hunt.traits.blank?

      unsuccessful_hunt( hunt.contract, hunt.traits ) unless dependency

      dependency.fetch hunt
    end


  end
end