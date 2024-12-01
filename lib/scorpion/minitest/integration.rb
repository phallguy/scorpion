require "scorpion"

module Scorpion
  module Minitest
    module Integration
      def self.included(base)
        base.infest_nest(ActionController::Base) if defined? ActionController::Base
        base.infest_nest(ActiveJob::Base)        if defined? ActiveJob::Base
        base.infest_nest(ActionMailer::Base)     if defined? ActionMailer::Base

        base.setup do
          @scorpion_env = {
            Scorpion::Rack::Middleware::ENV_KEY => scorpion,
          }
        end

        attr_reader(:scorpion_env)

        super
      end

      %w[get post patch put head delete].each do |method|
        module_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{method}(path, **args)

            env = args[:env] ||= {}
            env[Rack::Middleware::ENV_KEY] ||= scorpion

            super
          end
        RUBY
      end
    end
  end
end
