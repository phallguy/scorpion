module Scorpion
  module Rack
    module Env
      def self.create( * )
        fail "Include Scorpion::Rails::Controller in your ApplicationController" if defined? Rails
        fail "Add Scorpion::Rack::Middleware"
      end
    end
  end
end