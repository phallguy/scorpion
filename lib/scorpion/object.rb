require 'scorpion/attribute_set'

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
    def inject( attribute, dependency )
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
          def self.spawn( hunt, *args, **dependencies, &block )
            object =
              if dependencies.any?
                new( *args, **dependencies, &block )
              else
                new( *args, &block )
              end


            object.send :scorpion=, hunt.scorpion

            # Go hunt for dependencies that are not lazy and initialize the
            # references.
            hunt.inject object
            object.send :on_injected

            object
          end

        end

        base.subclasses.each do |sub|
          infest( sub ) unless sub < Scorpion::Object
        end
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

      # Called after the object has been initialized and feed all its required
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

          if overwrite || !self.send( "#{ attr.name }?" )
            self.send( "#{ attr.name }=", dependencies[ attr.name ] )
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

          if overwrite || !self.send( "#{ attr.name }?" )
            self.send( "#{ attr.name }=", val )
          end
        end

        dependencies
      end

    module ClassMethods

      # Define an initializer that accepts injections.
      # @param [Hash] arguments to accept in the initializer.
      # @yield to initialize itself.
      def initialize( arguments = {}, &block )
        Scorpion::ObjectConstructor.new( self, arguments, &block ).define
      end

      # Tells a {Scorpion} what to inject into the class when it is constructed
      # @return [nil]
      # @see AttributeSet#define
      def depend_on( arguments = nil, &block )
        Scorpion::ObjectConstructor.new( self, arguments ).define if arguments.present?
        injected_attributes.define &block
        build_injected_attributes
      end
      alias_method :inject, :depend_on
      alias_method :depend_on, :depend_on

      # Define a single dependency and accessor.
      # @param [Symbol] name of the dependency.
      # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
      # @param [Array<Symbol>] traits found on the {Dependency}.
      def attr_dependency( name, contract, *traits, &block )
        attr = injected_attributes.define_attribute name, contract, *traits, &block
        build_injected_attribute attr
        set_injected_attribute_visibility attr
      end

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attriutes.
      def injected_attributes
        @injected_attributes ||= begin
          attrs = AttributeSet.new
          attrs.inherit! superclass.injected_attributes if superclass.respond_to? :injected_attributes
          attrs
        end
      end

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attriutes.
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

        def build_injected_attributes
          injected_attributes.each do |attr|
            build_injected_attribute attr
            set_injected_attribute_visibility attr
          end
        end

        def build_injected_attribute( attr )
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ attr.name }
              @#{ attr.name } ||= begin
                attr = injected_attributes[ :#{ attr.name } ]
                scorpion.fetch_by_traits( attr.contract, attr.traits )
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

        def set_injected_attribute_visibility( attr )
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