module Scorpion
  module Rails
    module ActiveRecord
      # Adds dependency injection to ActiveRecord::Base model associations.
      module Association
        include Scorpion::Stinger

        # ============================================================================
        # @!group Attributes
        #

        include Scorpion::Method

        def scorpion(scope = nil)
          super || owner.scorpion(scope)
        end

        #
        # @!endgroup Attributes

        # Make sure we override the methods of child classes as well.
        def self.prepended(base)
          infect(base)
          super
        end

        # Propagate the module inheritance to all derived classes so that we can
        # always overlay our interception methods on the top-most overriden
        # method.
        def self.infect(klass)
          klass.class_exec do
            def self.inherited(from)
              Scorpion::Rails::ActiveRecord::Association.infect(from)

              super
            end
          end
          overlay(klass)
        end

        # Overlay interception methods on the klass.
        def self.overlay(klass)
          %i[load_target target reader writer scope].each do |method|
            next unless klass.instance_methods.include?(method)

            mod = Module.new do
              module_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{method}( *args, &block )
                  sting! super
                end
              RUBY
            end

            klass.prepend(mod)
          end
        end
      end
    end
  end
end
