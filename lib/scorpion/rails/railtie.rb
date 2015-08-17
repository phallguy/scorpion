require 'rails/railtie'

module Scorpion
  module Rails
    class Railtie < ::Rails::Railtie

      initializer "scorpion.configure" do |app|
        ::ActionController::Base.send :include, Scorpion::Rails::Controller
        ::ActiveJob::Base.send :include, Scorpion::Rails::Job
        ::ActionMailer::Base.send :include, Scorpion::Rails::Mailer

        ::Scorpion::Rails::ActiveRecord.install!
      end

    end
  end
end
