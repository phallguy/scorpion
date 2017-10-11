module Scorpion
  # An injected attribute and it's configuration.
  class Attribute

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Symbol] the name of the attribute.
      attr_reader :name

    # @!attribute
    # @return [Class,Module,Symbol] contract that describes the desired behavior
    #   of the injected object.
      def contract
        @contract = @contract.constantize if @contract.is_a? String
        @contract
      end

    # @!attribute
    # @return [Boolean] true if the attribute is not immediately required and
    #   will be hunted down on first use.
      def lazy?
        @lazy
      end

    # @!attribute
    # @return [Boolean] true if the attribute should have a public writer.
      def public?
        @public
      end

    # @!attribute
    # @return [Boolean] true if the attribute should have a public writer.
      def private?
        @private
      end

    #
    # @!endgroup Attributes


    def initialize( name, contract, lazy: false, public: false, private: false )
      @name      = name.to_sym
      @contract  = contract
      @lazy      = lazy
      @public    = public
      @private   = private
    end

  end
end
