require 'scorpion/attribute_set'

module Scorpion
  # Identifies objects that are served by {Scorpion scorpions} that feed on
  # {Scorpion#hunt! hunted} prey.
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

    def initialize( *args, &block )
      binding.pry
      super
    end


    def self.included( base )
      base.extend Scorpion::King::ClassMethods
      Scorpion::King::ClassMethods.build_spawn_method( base ) if base.is_a? Class

      super
    end

    def self.prepended( base )
      base.extend Scorpion::King::ClassMethods
      Scorpion::King::ClassMethods.build_spawn_method( base ) if base.is_a? Class

      super
    end

    private

      # Called after the king has been initialized and feed all its required
      # dependencies. It should be used in place of #initialize when the
      # constructor needs access to injected attributes.
      def on_fed
      end

    module ClassMethods

      # Tells a {Scorpion} what to inject into the class when it is constructed
      # @return [nil]
      # @see AttributeSet#define
      def feed_on( &block )
        injected_attributes.define &block
        build_injected_attributes
      end
      alias_method :inject, :feed_on

      # @!attribute
      # @return [Scorpion::AttributeSet] the set of injected attriutes.
      def injected_attributes
        @injected_attributes ||= AttributeSet.new
      end

      # @!method spawn( *args, &block )
      # Same as {#new} but handles injecting expected dependencies
      # @return [Object] the new object
      def self.build_spawn_method( base )
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.spawn( scorpion, *args, &block )

            new( *args, &block ).tap do |king|
              king.instance_variable_set :@scorpion, scorpion
              # Go hunt for dependencies that are not lazy and initialize the
              # references.
              scorpion.feed! king
              king.send :on_fed
            end
          end
        RUBY
      end

      private

        def build_injected_attributes
          injected_attributes.each do |attr|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{ attr.name }
                @#{ attr.name } ||= begin
                  attr = injected_attributes[ :#{ attr.name } ]
                  scorpion.hunt!( attr.contract, attr.traits )
                end
              end

              def #{ attr.name }=( value )
                @#{ attr.name } = value
              end
              private :#{ attr.name }=
            RUBY
          end
        end
    end
  end
end