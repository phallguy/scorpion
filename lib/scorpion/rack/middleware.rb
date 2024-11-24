require "scorpion/rack/env"

module Scorpion
  module Rack
    class Middleware
      ENV_KEY = "scorpion.instance".freeze

      def initialize(app, nest = nil)
        @app  = app
        @nest = nest
      end

      def call(env)
        # If we don't have a nest yet, build one from the configured global
        # scorpion.
        @nest ||= Scorpion.instance.build_nest

        conceived = false
        env[ENV_KEY] ||=
          begin
            conceived = true
            nest.conceive
          end

        prepare_scorpion(env[ENV_KEY], env)

        @app.call(env).tap do
          free_scorpion(env) if conceived
        end
      end

      private

        attr_reader :nest

        def prepare_scorpion(scorpion, env)
          scorpion.hunt_for(Rack::Env, return: env)
          scorpion
        end

        def free_scorpion(env)
          env[ENV_KEY].destroy
        end
    end
  end
end