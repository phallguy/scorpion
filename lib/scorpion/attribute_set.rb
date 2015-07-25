require 'scorpion/attribute'

module Scorpion
  class AttributeSet
    include Enumerable

    def initialize( attributes = {} )
      @attributes = attributes
    end

    def []( key )
      attributes.fetch( key )
    end

    def each( &block )
      attributes.each do |k,v|
        yield v
      end
    end

    # Merge two sets and create another.
    def merge( other )
      AttributeSet.new attributes.merge( other.attributes )
    end
    alias_method :|, :merge

    # Inherit attribute definitions from another set.
    def inherit!( other )
      other.each do |attr|
        attributes[attr.name] ||= attr
      end
    end

    def key?( name )
      attributes.key? name
    end

    # Defines the food that {Scorpion::Object} will feed on. A food is defined by
    # invoking a method with the desired name passing the contract and traits
    # desired. AttributeSet uses method_missing to dynamically define
    # attributes.
    #
    # If the block takes an argument, AttributeSet will yield to the block
    # passing itself. If no argument is provided, yield will use the
    # AttributeSet itself as the calling context.
    #
    # @example With Argument
    #
    #   define do |set|
    #     set.logger Rails::Logger
    #   end
    #
    # @example Without Argument
    #
    #   define do
    #     logger Rails::Logger, :color
    #   end
    def define( &block )
      return unless block_given?

      @defining_attributes = true
      if block.arity == 1
        yield self
      else
        instance_eval &block
      end

      self
    ensure
      @defining_attributes = false
    end

    # Define a single attribute with the given name that expects food that will
    # satisfy the contract and traits.
    # @param [String] name of the attribute.
    # @param [Class,Module,Symbol] contract that describes the desired behavior
    #   of the injected object.
    # @param [Array<Symbol>] traits that must match on instances of the {#contract}
    # @return [Attribute] the attribute that was created.
    def define_attribute( name, contract, *traits )
      options = traits.pop if traits.last.is_a? Hash
      options ||= {}
      attributes[name.to_sym] = Attribute.new name, contract, traits, options
    end


    protected

      attr_reader :attributes

    private

      def method_missing( name, *args )
        return super unless @defining_attributes

        if args.length >= 1
          define_attribute name, *args
        else
          super
        end
      end

  end
end