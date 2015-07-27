module Scorpion
  module Rails
    module ActiveRecord

      # Make sure that all models return by the relation inherit the relation's
      # scorpion.
      module Relation
        include Scorpion::Stinger

        # ============================================================================
        # @!group Attributes
        #

        # @!attribute
        # @return [Scorpion] the scorpion serving the relation.
          attr_accessor :scorpion

        #
        # @!endgroup Attributes

        # Elect to use a specific scorpion for all further operations in the
        # chain.
        #
        # @example
        #
        #   User.all.with_scorpion( scorpion ).where( ... )
        #   User.with_scorpion( scorpion ).where( ... )
        def with_scorpion( scorpion )
          spawn.tap do |other|
            other.scorpion = scorpion
          end
        end


        # from ActiveRecord::Relation
        [ :new, :build, :create, :create! ].each do |method|
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{ method }( *args, &block )
              super *args do |*block_args|
                sting!( block_args )
                yield *block_args if block_given?
              end
            end
          EOS
        end

        # from ActiveRecord::SpawnMethods
        def spawn
          sting!( super )
        end

        private
          # from ActiveRecord::Relation
          def exec_queries( *args, &block )
            sting!( super )
          end

          # from ActiveRecord::SpawnMethods
          def relation_with( *args )
            sting!( super )
          end

      end
    end
  end
end
