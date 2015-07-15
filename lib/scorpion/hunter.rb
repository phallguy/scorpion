module Scorpion
  # A concrete implementation of a Scorpion used to hunt down food for a {Scorpion::King}.
  # @see Scorpion
  class Hunter
    include Scorpion

    # ============================================================================
    # @!group Attributes
    #

    # @return [Scorpion::HuntingMap] map of {Prey} and how to create instances.
      attr_reader :hunting_map
      protected :hunting_map

    # @return [Scorpion] parent scorpion to deferr hunting to on missing prey.
      attr_reader :parent
      private :parent

    #
    # @!endgroup Attributes

    def initialize( parent = nil, &block )
      @parent      = parent
      @hunting_map = Scorpion::HuntingMap.new( self )

      prepare &block if block_given?
    end

    # Prepare the scorpion for hunting.
    # @see HuntingMap#chart
    def prepare( &block )
      hunting_map.chart &block
    end

    # @see Scorpion#hunt!
    def hunt_by_traits!( contract, traits = nil, *args, &block  )
      unless prey = hunting_map.find( contract, traits )
        return parent.hunt_by_traits! contract, traits if parent
        unsuccessful_hunt!( contract, traits ) unless prey
      end
      prey.fetch self, *args, &block
    end

    # @see Scorpion#replicate
    def replicate
      replica = self.class.new self
      replica.hunting_map.replicate_from( hunting_map )
      replica
    end

  end
end