require "scorpion/nest"

module Scorpion
  module Rails

    # Adds a scorpion nest to support injection into rails background worker jobs.
    module Job


      def self.included( base )
        # Setup dependency injection
        base.send :include, Scorpion::Object
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

        attr_reader :scorpion
        def assign_scorpion( scorpion )
          @scorpion = scorpion
        end

        def free_scorpion
          @scorpion.try( :destroy )
          @scorpion = nil
        end
    end
  end
end