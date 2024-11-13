module Scorpion
  module Rails
    module ActiveRecord
      # Adds dependency injection to ActiveRecord::Base models.
      module Model
        include Scorpion::Stinger

        def self.prepended(base)
          # Setup dependency injection
          base.send(:include, Scorpion::Object)
          base.singleton_class.class_exec do
            delegate(:with_scorpion, to: :all)
          end

          super
        end

        def association(*args, &block)
          sting!(super)
        end
      end
    end
  end
end