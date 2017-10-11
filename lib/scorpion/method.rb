module Scorpion
  # Adds a #scorpion method to an object.
  module Method
    # @overload scorpion
    #   @return [Scorpion] the object's scorpion used to hunt down dependencies.
    # @overload scorpion( scope )
    #   Stings the given `scope` with the current scorpion.
    #   @param [#with_scorpion] scope an object that responds to #with_scorpion that
    #     receives the current scorpion.
    #   @return [scope] stung object.
    def scorpion( scope = nil )
      if scope
        scope.with_scorpion( scorpion )
      else
        @scorpion
      end
    end

    private def scorpion=( value )
      @scorpion = value
    end

    # @!attribute
    # @return [Hunt] the scorpion hunt that captured the object.
    def scorpion_hunt
      @scorpion_hunt
    end

    private def scorpion_hunt=( hunt )
      @scorpion_hunt = hunt
    end

  end
end
