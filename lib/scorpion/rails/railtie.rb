require "rails/railtie"
require "scorpion/rack/middleware"

module Scorpion
  module Rails
    class Railtie < ::Rails::Railtie

      initializer "scorpion.configure" do |_app|
        ::ActionController::Base.send :include, Scorpion::Rails::Controller if defined? ::ActionController
        ::ActiveJob::Base.send :include, Scorpion::Rails::Job if defined? ::ActiveJob
        ::ActionMailer::Base.send :include, Scorpion::Rails::Mailer if defined? ::ActionMailer

        ::Scorpion::Rails::ActiveRecord.install! if defined? ::ActiveRecord
      end

    end
  end
end
