require "rails/railtie"
require "scorpion/rack/middleware"

module Scorpion
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "scorpion.configure" do |_app|
        ActiveSupport.on_load(:action_controller) { include Scorpion::Rails::Controller } if defined? ::ActionController
        ActiveSupport.on_load(:active_job) { include Scorpion::Rails::Job } if defined? ::ActiveJob
        ActiveSupport.on_load(:action_mailer) { include Scorpion::Rails::Mailer } if defined? ::ActionMailer

        ::Scorpion::Rails::ActiveRecord.install! if defined? ::ActiveRecord
      end

      initializer "scorpion.insert_middleware" do |app|
        app.config.middleware.unshift(Scorpion::Rack::Middleware)
      end
    end
  end
end
