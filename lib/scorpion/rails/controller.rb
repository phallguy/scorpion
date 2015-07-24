require 'scorpion/nest'
require 'active_support/core_ext/class/attribute'

module Scorpion
  module Rails
    # Adds a scorpion nest to rails controllers to automatically support
    # injection into rails controllers.
    module Controller

      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Rails::Nest
        base.around_action :with_scorpion
        super
      end

      private

        # Fetch a scorpion and feed the controller it's dependencies
        def prepare_scorpion( scorpion )
          scorpion.prepare do |hunter|
            # Allow dependencies to access the controller
            hunter.hunt_for AbstractController::Base, capture: self

            # Allow dependencies to access the current request/response
            hunter.hunt_for ActionDispatch::Request do |hunter|
              hunter.hunt( AbstractController::Base ).request
            end
            hunter.hunt_for ActionDispatch::Response do |hunter|
              hunter.hunt( AbstractController::Base ).response
            end
          end
        end
    end
  end
end