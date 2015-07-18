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
      attr_reader :contract

    # @!attribute
    # @return [Array<Symbol>] traits that must match on instances of the {#contract}
      attr_reader :traits

    # @!attribute
    # @return [Boolean] true if the attribute is not immediately required and
    #   will be hunted down on first use.
      def lazy?; @lazy end

    # @!attribute
    # @return [Boolean] true if the attribute should have a public writer.
      def public?; @public end

    # @!attribute
    # @return [Boolean] true if the attribute should have a public writer.
      def private?; @private end


    #
    # @!endgroup Attributes


    def initialize( name, contract, traits = nil, options = {} )
      @name      = name.to_sym
      @contract  = contract
      @traits    = Array( traits ).flatten.freeze
      @trait_set = Set.new( @traits.map{ |t| :"#{t}?" } )
      @lazy      = options.fetch( :lazy, false )
      @public    = options.fetch( :public, false )
      @private   = options.fetch( :private, false )
    end

    def respond_to?( name, include_all = false )
      super || trait_set.include?( name )
    end

    private
      # @return [Set] the set of traits associated with the attribute pre-processed
      #   to include the trait names with a '?' suffix.
        attr_reader :trait_set

      def method_missing( name, *args )
        if is_trait_method?( name )
          trait_set.include? name
        else
          super
        end
      end

      def is_trait_method?( name )
        name[-1] == '?'
      end
  end
end