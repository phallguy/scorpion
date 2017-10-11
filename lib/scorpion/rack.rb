module Scorpion

  # Add scorpion support to a Rack middleware.
  module Rack
    private

      def scorpion( env )
        env[ Middleware::ENV_KEY ] || fail( MissingScorpionError, self.class.name )
      end
  end
end

require "scorpion/rack/env"
require "scorpion/rack/middleware"
require "scorpion/rack/missing_scorpion_error"
