# frozen_string_literal: true

require "scorpion"

module Scorpion
  module Minitest
    def self.scorpion_nest
      @scorpion_nest ||= Scorpion.instance.build_nest
    end

    def self.prepare(&block)
      scorpion_nest.prepare(&block)
    end

    def self.included(base)
      base.send(:extend, Scorpion::Minitest::Methods)

      base.define_method(:scorpion) do
        Scorpion::Minitest.scorpion_nest.conceive
      end

      base.infest_nest(ActionController::Base) if defined? ActionController::Base
      base.infest_nest(ActiveJob::Base)        if defined? ActiveJob::Base
      base.infest_nest(ActionMailer::Base)     if defined? ActionMailer::Base

      base.teardown do
        scorpion.destroy
      end

      super
    end

    module Methods
      def infest_nest(klass)
        return unless klass < Scorpion::Rails::Nest
      end

      def hunt(...)
        debugger
        super
      end
    end
  end
end
