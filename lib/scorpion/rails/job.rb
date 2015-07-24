require 'scorpion/nest'
require 'active_support/core_ext/class/attribute'

module Scorpion
  module Rails

    # Adds a scorpion nest to  to automatically support injection into rails
    # background worker jobs.
    module Job

      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Rails::Nest
        base.send :around_perform, :with_scorpion
        super
      end

      private

        def prepare_scorpion( scorpion )
          scorpion.prepare do |hunter|
            hunter.hunt_for ActiveJob::Base do
              self
            end
          end
        end
    end
  end
end