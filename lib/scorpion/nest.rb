module Scorpion
  # A scorpion factory
  class Nest
    # ============================================================================
    # @!group Associations
    #

    # @!attribute
    # @return [Scorpion] the mother scorpion that that will {#conceive} new
    #   scorpions for each request.
    attr_reader :mother

    #
    # @!endgroup Associations

    def initialize(mother = nil)
      @mother = mother || Scorpion::Hunter.new
    end

    def prepare(&block)
      mother.prepare(&block)
    end

    # @return [Scorpion] a new scorpion used to hunt for dependencies.
    def conceive
      mother.replicate
    end

    # Free up any persistent resources
    def destroy
      mother.destroy
      @mother = nil
    end

    # Reset the hunting map and clear all dependencies.
    def reset
      mother.reset
    end
  end
end