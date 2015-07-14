module Scorpion
  # An injected attribute and it's configuration.
  class Attribute

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Symbol] the name of the attribute.
      attr_accessor :name

    # @!attribute
    # @return [Class,Module,Symbol] contract that describes the desired behavior
    #   of the injected object.
      attr_accessor :contract

    # @!attribute
    # @return [Array<Symbol>] traits that must match on instances of the {#contract}
      attr_accessor :traits

    # @!attribute
    # @return [Boolean] true if the attribute is not immediately required and
    #   will be hunted down on first use.
      attr_accessor :lazy
      alias_method :lazy?, :lazy

    #
    # @!endgroup Attributes


    def initialize( name, contract, *traits, options )
      @name     = name.to_sym
      @contract = contract
      @traits   = traits.flatten
      @lazy     = options.fetch( :lazy, false )
    end
  end
end