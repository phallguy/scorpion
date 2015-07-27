module Scorpion
  module Rails
    module ActiveRecord

      # Adds dependency injection to ActiveRecord::Base model associations.
      module Association
        include Scorpion::Stinger

        # ============================================================================
        # @!group Attributes
        #

        # @!attribute
        # @return [Scorpion] the scorpion serving the association.
          attr_accessor :scorpion
          def scorpion
            @scorpion || owner.scorpion
          end

        #
        # @!endgroup Attributes


        # Make sure we override the methods of child classes as well.
        def self.prepended( base )
          infect base
          super
        end

        # Propagate the module inheritance to all derived classes so that we can
        # always overlay our interception methods on the top-most overriden
        # method.
        def self.infect( klass )
          klass.class_exec do
            def self.inherited( from )
              Scorpion::Rails::ActiveRecord::Association.infect( from )

              super
            end
          end
          overlay( klass )
        end

        # Overlay interception methods on the klass.
        def self.overlay( klass )
          [ :load_target, :target, :reader, :writer, :scope ].each do |method|
            next unless klass.instance_methods.include? method

            mod = Module.new do
              module_eval <<-EOS, __FILE__, __LINE__ + 1
                def #{ method }( *args, &block )
                  sting! super
                end
              EOS
            end

            klass.prepend mod
          end
        end

      end

    end
  end
end