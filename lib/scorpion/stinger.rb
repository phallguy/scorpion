module Scorpion
  # Utility methods for propagating a Scorpion to returned objects.
  module Stinger
    @wrappers ||= {}

    def self.wrap( instance, stinger )
      return instance unless instance

      klass = @wrappers[instance.class] ||=
        Class.new( instance.class ) do
          def initialize( instance, stinger )
            @__instance__ = instance
            @__stinger__  = stinger
          end

          def respond_to?( *args )
            @__instance__.respond_to?( *args )
          end

          private
            def method_missing( *args, &block )
              @__stinger__.sting! @__instance__.__send__( *args, &block )
            end
        end

      klass.new instance, stinger
    end

    # Sting an object so that it will be injected with the scorpion and use it
    # to resolve all dependencies.
    # @param [#scorpion] object to sting.
    # @return [object] the object that was stung.
    def sting!( object )
      return object unless scorpion

      if object
        assign_scorpion object
        assign_scorpion_to_enumerable object
      end

      object
    end

    private

      def assign_scorpion( object )
        return unless object.respond_to?( :scorpion=, true )

        # Only set scorpion if it hasn't been set yet.
        current_scorpion = object.send :scorpion
        if current_scorpion
          scorpion.logger.warn I18n.translate :mixed_scorpions, scope: [:scorpion,:warnings,:messages] if current_scorpion != scorpion
        else
          object.send :scorpion=, scorpion
        end
      end

      def assign_scorpion_to_enumerable( objects )
        return unless objects.respond_to? :each

        # Don't eager load relations that haven't been loaded yet.
        return if objects.respond_to?( :loaded? ) && ! objects.loaded?

        objects.each{ |v| sting! v }
      end

  end
end
