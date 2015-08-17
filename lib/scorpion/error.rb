require 'i18n'

module Scorpion
  class Error < StandardError

    private
      def translate( key, args = {} )
        I18n.translate key, args.merge( scope: [:scorpion,:errors,:messages] )
      end
  end

  class UnsuccessfulHunt < Error
    attr_reader :contract
    attr_reader :traits

    def initialize( contract, traits = nil )
      @contract = contract
      @traits   = traits

      super translate( :unsuccessful_hunt, contract: contract, traits: traits )
    end
  end

  class ArityMismatch < Error
    def initialize( block, expected_count )
      super translate( :arity_mismatch, expected: expected_count, actual: block.arity )
    end
  end

  class BuilderRequiredError < Error
    def initialize( message = nil )
      super ( message || translate( :builder_required ) )
    end
  end
end