require 'scorpion/nest'
require 'active_support/core_ext/class/attribute'

module Scorpion
  module Rails
    # Adds a scorpion nest to rails controllers to automatically support
    # injection into rails controllers.
    module Controller

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
        base.send :include, Scorpion::King
        base.around_action :with_scorpion

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
          # @see HuntingMap#chart
          def self.scorpion_nest( &block )
            nest.prepare &block
          end
        end
        base.nest ||= Scorpion::Nest.new

        super
      end

      private

        # Fetch a scorpion and feed the controller it's dependencies
        def with_scorpion( &block )
          @scorpion = nest.conceive

          @scorpion.prepare do |hunter|
            hunter.hunt_for AbstractController::Base do
              self
            end
            # Allow dependencies to access the current request/response
            hunter.hunt_for ActionDispatch::Request do |hunter|
              hunter.hunt!( AbstractController::Base ).request
            end
            hunter.hunt_for ActionDispatch::Response do |hunter|
              hunter.hunt!( AbstractController::Base ).response
            end
          end

          @scorpion.feed! self

          yield
        ensure
          @scorpion = nil
        end
    end
  end
end