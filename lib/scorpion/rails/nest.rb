require "scorpion/nest"
require "active_support/core_ext/class/attribute"

module Scorpion
  module Rails
    # Handles building a scorpion to handle a single request and populating
    # all the dependencies automatically.
    #
    # The host class must respond to #scorpion, #assign_scorpion(scorpion) and
    # #free_scorpion.
    module Nest
      include Scorpion::Object

      # ============================================================================
      # @!group Attributes
      #

      # @!attribute
      # @return [Scorpion::Nest] the nest used to conceive scorpions.
        def nest
          self.class.nest
        end
        private :nest

        def scorpion( scope = nil )
          # Make sure a scorpion is always available. Will be freed on the next
          # call to #with_scorpion
          ensure_scorpion( super ) unless scope
          super
        end

      #
      # @!endgroup Attributes

      def self.included( base ) # rubocop:disable Metrics/MethodLength
        # @!attribute [rw]
        # @return [Scorpion::Nest] the singleton nest used by controllers.
        base.class_attribute :nest_instance
        base.class_exec do

          # @!attribute
          # @return [Scorpion::Nest] the nest used to conceive scorpions to
          #   hunt for objects on each request.
          def self.nest
            nest_instance || ( self.nest = Scorpion.instance.build_nest )
          end

          def self.nest=( value )
            nest_instance&.destroy
            self.nest_instance = value
          end

          # Prepare the nest for conceiving scorpions.
          # @see DependencyMap#chart
          def self.scorpion_nest( &block )
            nest.prepare &block
          end

          # Define dependency resolution that isn't resolved until an instance
          # of a scorpion is conceived to handle an idividual request.
          # @param (see DependencyMap#hunt_for )
          def self.hunt_for( *args, &block )
            instance_hunts << [:hunt_for, args, block]
          end

          # Define dependency resolution that isn't resolved until an instance
          # of a scorpion is conceived to handle an idividual request.
          # @param (see DependencyMap#capture )
          def self.capture( *args, &block )
            instance_hunts << [:capture, args, block]
          end

          # Hunting dependencies that cannot be resolved until an instance
          # of the nest class has been created.
          def self.instance_hunts
            @instance_hunts ||= begin
              if superclass.respond_to?( :instance_hunts )
                superclass.instance_hunts.dup
              else
                []
              end
            end
          end
        end


        super
      end

      private

      # Fetch a scorpion and feed the controller it's dependencies, then yield
      # to perform the action within the context of that scorpion.
      def with_scorpion( &block )
        ensure_scorpion( scorpion )
        scorpion.inject self

        yield
      ensure
        free_scorpion
      end

      def conceive_scorpion
        @conceived_scorpion = true
        nest.conceive
      end

      def conceived_scorpion?
        !!@conceived_scorpion
      end

      def append_instance_hunts( scorpion )
        scorpion.prepare do |hunter|
          self.class.instance_hunts.each do |method, args, block|
            hunter.send method, *args do |*method_args|
              instance_exec *method_args, &block
            end
          end
        end
      end

      def ensure_scorpion( existing )
        scorpion = existing
        scorpion = assign_scorpion( conceive_scorpion ) unless existing

        prepare_scorpion( scorpion ) if respond_to?( :prepare_scorpion, true )
        append_instance_hunts( scorpion )
        scorpion
      end

    end
  end
end
