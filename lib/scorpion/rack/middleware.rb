require "scorpion/rack/env"

module Scorpion
  module Rack
    class Middleware

      ENV_KEY = "scorpion.rack.instance".freeze

      def initialize( app, nest = nil )
        @app  = app
        @nest = nest || Scorpion.instance.build_nest
      end

      def call( env )
        env[ENV_KEY] = prepare_scorpion( nest.conceive, env )
        @app.call(env).tap do
          free_scorpion( env )
        end
      end

      private

        attr_reader :nest

        def prepare_scorpion( scorpion, env )
          scorpion.hunt_for Rack::Env, return: env
          scorpion
        end

        def free_scorpion( env )
          env[ENV_KEY].destroy
        end
    end
  end
end