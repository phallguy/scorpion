require 'scorpion/nest'

module Scorpion
  module Rails

    # Adds a scorpion nest to support injection into rails controllers.
    module Controller

      ENV_KEY = 'scorpion.instance'.freeze

      def scorpion
        env[ENV_KEY]
      end

      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Rails::Nest
        base.around_filter :with_scorpion
        super
      end

      private

        # Fetch a scorpion and feed the controller it's dependencies
        def prepare_scorpion( scorpion )
          scorpion.prepare do |hunter|
            # Allow dependencies to access the controller
            hunter.hunt_for AbstractController::Base, return: self

            # Allow dependencies to access the current request/response
            hunter.hunt_for ActionDispatch::Request do |hunt|
              hunt.fetch( AbstractController::Base ).request
            end
            hunter.hunt_for ActionDispatch::Response do |hunt|
              hunt.fetch( AbstractController::Base ).response
            end
          end
        end

        def assign_scorpion( scorpion )
          env[ENV_KEY] = scorpion
        end

        def free_scorpion
        end

    end
  end
end