require "scorpion/attribute_set"

module Scorpion
  # Identifies objects that are injected by {Scorpion scorpions} that inject
  # {Scorpion#hunt hunted} dependencies.
  module Object

    # ============================================================================
    # @!group Attributes
    #

    include Scorpion::Method

    # @!attribute
    # @return [Scorpion::AttributeSet] the set of injected attributes and their
    #   settings.
      def injected_attributes
        self.class.injected_attributes
      end

    #
    # @!endgroup Attributes

    # Injects one of the {#injected_attributes} into the object.
    # @param [Scorpion::Attribute] attribute to be fed.
    # @param [Object] dependency the value of the attribute
    # @visibility private
    #
    # This method is used by the {#scorpion} to feed the object. Do not call it
    # directly.
    def inject_dependency( attribute, dependency )
      send "#{ attribute.name }=", dependency
    end

    # Infest the object with a scoprion and prepare it to be fed.
    def self.infest( base )
      base.extend Scorpion::Object::ClassMethods
      if base.is_a? Class
        base.class_exec do

          # Create a new instance of this class with all non-lazy dependencies
          # satisfied.
          # @param [Hunt] hunt that this instance will be used to satisfy.
          def self.spawn( hunt, *args, &block )
            object = new( *args, &block )
            object.send :scorpion=, hunt.scorpion

            # Go hunt for dependencies that are not lazy and initialize the
            # references.
            hunt.inject object
            object
          end

        end

        # base.subclasses.each do |sub|
        #   infest( sub ) unless sub < Scorpion::Object
        # end
      end
    end

    def self.included( base )
      infest( base )
      super
    end

    def self.prepended( base )
      infest( base )
      super
    end


    private

      # Called after the object has been initialized and fed all its required
      # dependencies. It should be used in place of #initialize when the
      # constructor needs access to injected attributes.
      def on_injected
      end

      # Feed dependencies from a hash into their associated attributes.
      # @param [Hash] dependencies hash describing attributes to inject.
      # @param [Boolean] overwrite existing attributes with values in in the hash.
      def inject_from( dependencies, overwrite = false )
        injected_attributes.each do |attr|
          next unless dependencies.key? attr.name

          if overwrite || !send( "#{ attr.name }?" )
            send( "#{ attr.name }=", dependencies[ attr.name ] )
          end
        end

        dependencies
      end

      # Injects dependenices from the hash and removes them from the hash.
      # @see #inject_from
      def inject_from!( dependencies, overwrite = false )
        injected_attributes.each do |attr|
          next unless dependencies.key? attr.name
          val = dependencies.delete( attr.name )

          if overwrite || !send( "#{ attr.name }?" )
            send( "#{ attr.name }=", val )
          end
        end

        dependencies
      end

    module ClassMethods

      # Tells a {Scorpion} what to inject into the class when it is constructed
      # @return [nil]
      # @see AttributeSet#define
      def depend_on( &block )
        injected_attributes.define &block
        build_injected_attributes
        validate_initializer_injections
      end

      # Define a single dependency and accessor.
      # @param [Symbol] name of the dependency.
      # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
      def attr_dependency( name, contract, **options, &block )
        attr = injected_attributes.define_attribute name, contract, **options, &block
        build_injected_attribute attr
        adjust_injected_attribute_visibility attr
        validate_initializer_injections
        attr
      end

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attributes.
      def injected_attributes
        @injected_attributes ||= begin
          attrs = AttributeSet.new
          attrs.inherit! superclass.injected_attributes if superclass.respond_to? :injected_attributes
          attrs
        end
      end

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attributes.
      def initializer_injections
        @initializer_injections ||= begin
          if superclass.respond_to?( :initializer_injections )
            superclass.initializer_injections
          else
            AttributeSet.new
          end
        end
      end

      private

        def validate_initializer_injections
          initializer_injections.each do |attr|
            injected = injected_attributes[ attr.name ]
            if injected.contract != attr.contract
              fail Scorpion::ContractMismatchError.new( self, attr, injected )
            end
          end
        end

        def build_injected_attributes
          injected_attributes.each do |attr|
            build_injected_attribute attr
            adjust_injected_attribute_visibility attr
          end
        end

        def build_injected_attribute( attr )
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ attr.name }
              @#{ attr.name } ||= begin
                attr = injected_attributes[ :#{ attr.name } ]
                ( scorpion_hunt || scorpion ).fetch( attr.contract )
              end
            end

            def #{ attr.name }=( value )
              @#{ attr.name } = value
            end

            def #{ attr.name }?
              !!@#{ attr.name }
            end
          RUBY
        end

        def adjust_injected_attribute_visibility( attr )
          unless attr.public?
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              private :#{ attr.name }=
              private :#{ attr.name }?
            RUBY
          end

          if attr.private?
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              private :#{ attr.name }
            RUBY
          end
        end
    end
  end
end
