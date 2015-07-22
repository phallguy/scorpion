require 'scorpion/attribute_set'

module Scorpion
  # Identifies objects that are served by {Scorpion scorpions} that feed on
  # {Scorpion#hunt hunted} prey.
  module King

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Scorpion] the scorpion used to hunt down prey.
      attr_reader :scorpion

    # @!attribute
    # @return [Scorpion::AttributeSet] the set of injected attributes and their
    #   settings.
      def injected_attributes
        self.class.injected_attributes
      end

    #
    # @!endgroup Attributes

    # Feeds one of the {#injected_attributes} to the object.
    # @param [Scorpion::Attribute] attribute to be fed.
    # @param [Object] food the value of the attribute
    # @visibility private
    #
    # This method is used by the {#scorpion} to feed the king. Do not call it
    # directly.
    def feed( attribute, food )
      send "#{ attribute.name }=", food
    end

    # Crown the object as a king and prepare it to be fed.
    def self.crown( base )
      base.extend Scorpion::King::ClassMethods
      if base.is_a? Class
        base.class_exec do

          # Span a new instance of this class with all non-lazy dependencies
          # satisfied.
          # @param [Scorpion] scorpion that will hunt for dependencies.
          def self.spawn( scorpion, *args, &block )
            new( *args, &block ).tap do |king|
              king.instance_variable_set :@scorpion, scorpion
              # Go hunt for dependencies that are not lazy and initialize the
              # references.
              scorpion.feed king
              king.send :on_fed
            end
          end
        end
      end
    end

      def self.included( base )
        crown( base )
        super
      end

      def self.prepended( base )
        crown( base )
        super
      end


    private

      # Called after the king has been initialized and feed all its required
      # dependencies. It should be used in place of #initialize when the
      # constructor needs access to injected attributes.
      def on_fed
      end

      # Convenience method to ask the {#scorpion} to hunt for an object.
      # @see Scorpion#hunt
      def hunt( contract, *args, &block )
        scorpion.hunt contract, *args, &block
      end

      # Convenience method to ask the {#scorpion} to hunt for an object.
      # @see Scorpion#hunt_by_traits
      def hunt_by_traits( contract, traits, *args, &block )
        scorpion.hunt_by_traits contract, *args, &block
      end

      # Feed dependencies from a hash into their associated attributes.
      # @param [Hash] dependencies hash describing attributes to inject.
      # @param [Boolean] overwrite existing attributes with values in in the hash.
      def feast_on( dependencies, overwrite = false )
        injected_attributes.each do |attr|
          next unless dependencies.key? attr.name

          if overwrite || !self.send( "#{ attr.name }?" )
            self.send( "#{ attr.name }=", dependencies[ attr.name ] )
          end
        end

        dependencies
      end
      alias_method :inject_from, :feast_on

      # Injects dependenices from the hash and removes them from the hash.
      # @see #feast_on
      def feast_on!( dependencies, overwrite = false )
        injected_attributes.each do |attr|
          next unless dependencies.key? attr.name
          val = dependencies.delete( attr.name )

          if overwrite || !self.send( "#{ attr.name }?" )
            self.send( "#{ attr.name }=", val )
          end
        end

        dependencies
      end
      alias_method :inject_from!, :feast_on!

    module ClassMethods

      # Tells a {Scorpion} what to inject into the class when it is constructed
      # @return [nil]
      # @see AttributeSet#define
      def feed_on(  &block )
        injected_attributes.define &block
        build_injected_attributes
      end
      alias_method :inject, :feed_on
      alias_method :depend_on, :feed_on

      # Define a single dependency and accessor.
      # @param [Symbol] name of the dependency.
      # @param [Class,Module,Symbol] contract describing the desired behavior of the prey.
      # @param [Array<Symbol>] traits found on the {Prey}.
      def attr_dependency( name, contract, traits = nil )
        attr = injected_attributes.define_attribute name, contract, traits
        build_injected_attribute attr
        set_injected_attribute_visibility attr
      end

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attriutes.
      def injected_attributes
        @injected_attributes ||= begin
          attr = AttributeSet.new
          attr.inherit! superclass.injected_attributes if superclass.respond_to? :injected_attributes
          attr
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
                scorpion.hunt( attr.contract, attr.traits )
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