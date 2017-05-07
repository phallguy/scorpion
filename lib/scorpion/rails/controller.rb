require 'scorpion/nest'

module Scorpion
  module Rails

    # Adds a scorpion nest to support injection into rails controllers.
    module Controller

      ENV_KEY = 'scorpion.controller.instance'.freeze


      # Fetch an object from the controller's {#scorpion}.
      # @see Scorpion#fetch
      def fetch( *args, &block )
        scorpion.fetch *args, &block
      end
      private :fetch


      # @overload scorpion
      #   @return [Scorpion] the current scorpion
      # @overload scorpion( scope )
      #   Stings the given `scope` with the current scorpion.
      #   @param [ActiveRecord::Relation,#with_scorpion] an ActiveRecord relation,
      #     scope or model class.
      #   @return [ActiveRecord::Relation] scorpion scoped relation.

      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Object
        base.send :include, Scorpion::Rails::Nest

        base.around_action :with_scorpion

        base.class_eval do
          # Defined here to override the #scorpion method provided by Scorpion::Object.
          def scorpion( scope = nil )
            if scope
              super
            else
              ensure_scorpion( request.env[ENV_KEY] )
            end
          end
        end

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

            hunter.hunt_for Scorpion::Rack::Env, return: request.env
          end
        end

        def assign_scorpion( scorpion )
          request.env[ENV_KEY] = scorpion
        end

        def free_scorpion
          scorpion.try( :destroy )
          request.env.delete ENV_KEY
        end

    end
  end
end
