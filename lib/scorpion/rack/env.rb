module Scorpion
  module Rack
    module Env
      def self.create(*)
        raise("Include Scorpion::Rails::Controller in your ApplicationController") if defined? Rails

        raise("Add Scorpion::Rack::Middleware")
      end
    end
  end
end