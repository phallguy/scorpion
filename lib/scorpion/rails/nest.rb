require 'scorpion/nest'
require 'active_support/core_ext/class/attribute'

module Scorpion
  module Rails
    # Handles building a scorpion to handle a single request and populating
    # all the dependencies automatically.
    module Nest

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [Scorpion] the scorpion used to fetch dependencies.
        attr_reader :scorpion
        private :scorpion

      # @!attribute
      # @return [Scorpion::Nest] the nest used to conceive scorpions.
        def nest
          self.class.nest
        end
        private :nest

      #
      # @!endgroup Attributes

      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Object

        # @!attribute [rw]
        # @return [Scorpion::Nest] the singleton nest used by controllers.
        base.class_attribute :nest_instance
        base.class_exec do

          # @!attribute
          # @return [Scorpion::Nest] the nest used to conceive scorpions to
          #   hunt for objects on each request.
          def self.nest
            nest_instance
          end
          def self.nest=( value )
            nest_instance.destroy if nest_instance
            self.nest_instance = value
          end

          # Prepare the nest for conceiving scorpions.
          # @see DependencyMap#chart
          def self.scorpion_nest( &block )
            nest.prepare &block
          end
        end
        base.nest ||= Scorpion.instance.build_nest

        super
      end

      # Fetch a scorpion and feed the controller it's dependencies, then yield
      # to perform the action within the context of that scorpion.
      def with_scorpion( &block )
        assign_scorpion( nest.conceive )

        prepare_scorpion( @scorpion ) if respond_to?( :prepare_scorpion, true )

        hunt = Scorpion::Hunt.new @scorpion, nil, nil
        hunt.inject self

        yield
      ensure
        free_scorpion
      end

      private

        def assign_scorpion( scorpion )
          @scorpion = scorpion
        end

        def free_scorpion
          @scorpion = nil
        end
    end
  end
end