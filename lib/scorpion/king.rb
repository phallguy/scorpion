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


    def self.included( base )
      base.extend Scorpion::King::ClassMethods
      Scorpion::King::ClassMethods.build_spawn( base ) if base.is_a? Class
    end

    private
      def feed( attribute, food )
        send "#{ attribute.name }=", food
      end

    module ClassMethods

      # Tells a {Scorpion::Scorpion} what to inject into the class when it is constructed
      # @param [Array<Symbol>] args named arguments that are require
      # @return [nil]
      def feed_on( &block )
        puts "Inject #{ self }"

        injected_attributes.define &block
        injected_attributes.each do |attr|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ attr.name }
              @#{ attr.name } ||= scorpion.hunt!( injected_attributes[ :#{ attr.name } ], self )
            end

            def #{ attr.name }=( value )
              @#{ attr.name } = value
            end
            private :#{ attr.name }
          RUBY
        end
      end

      # @return [Scorpion::AttributeSet] the set of injected attriutes.
      def injected_attributes
        @injected_attributes ||= AttributeSet.new
      end

      def inherited( base )
        puts "Inherited #{base}"
      end

      # @!method spawn( *args, &block )
      # Same as {#new} but handles injecting expected dependencies
      # @return [Object] the new object
      def self.build_spawn( base )
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.spawn( scorpion, *args, &block )
            args, injected_args = extract_injections( args )

            new( *args, &block ).tap do |king|
              king.instance_variable_set :@scorpion, scorpion
              scorpion.feed! king
            end
          end
        RUBY
      end

      private

        # Extracts any manually specified injections from the last arg if it is a
        # hash.
        def extract_injections( args )
          hash = args.last
          if hash.is_a? Hash
            split_injected_args args
          else
            [ args, nil ]
          end
        end

        def split_injected_args( args )
          hash     = args.last
          options  = nil
          injected = {}

          injected_attributes.each do |attr|
            next unless  hash.key? attr.name

            unless options
              options = hash.dup
              args = args[0...-1] + [options]
            end
            injected[attr.name] = options.delete attr.name
          end

          [ args, injected ]
        end
    end
  end
end