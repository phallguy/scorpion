module Scorpion

  # Chains hunting calls to one or more managed scorpions.
  class ChainHunter
    include Scorpion

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Array<Scorpion>] scorpions to chain hunting calls to.
    attr_reader :scorpions

    #
    # @!endgroup Attributes


    def initialize( *scorpions )
      @scorpions = scorpions
    end

    # Prepare the scorpion for hunting.
    # @see DependencyMap#chart
    def prepare( &block )
      if top = scorpions.first
        top.prepare &block
      end
    end

    # @see Scorpion#replicate
    def replicate
      self.class.new *scorpions.map( &:replicate )
    end

    # @see Scorpion#hunt
    def execute( hunt )
      # Try explicitly defined dependencies first
      scorpions.each do |hunter|
        begin
          return hunter.execute( hunt, true )
        rescue UnsuccessfulHunt
        end
      end

      # Then allow implicit
      scorpions.each do |hunter|
        begin
          return hunter.execute( hunt )
        rescue UnsuccessfulHunt
        end
      end

      unsuccessful_hunt hunt.contract, hunt.traits
    end

  end
end