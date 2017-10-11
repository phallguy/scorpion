require "i18n"

module Scorpion
  class Error < StandardError

    private

      def translate( key, **args )
        I18n.translate key, args.merge( scope: [:scorpion, :errors, :messages] )
      end

  end

  class UnsuccessfulHunt < Error
    attr_reader :contract

    def initialize( contract )
      @contract = contract

      super translate( :unsuccessful_hunt, contract: contract )
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

  class ContractMismatchError < Error
    def initialize( message_or_module = nil, initializer_attr = nil, injected_attr = nil )
      if message_or_module.is_a?( Module )
        super translate( :contract_mismatch, module: message_or_module,
                                             name: initializer_attr.name,
                                             from: initializer_attr.contract,
                                             to: injected_attr.contract )
      else
        super ( message || translate( :contract_mismatch ) )
      end
    end
  end
end
