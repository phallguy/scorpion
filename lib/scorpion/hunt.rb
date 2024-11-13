module Scorpion
  # Captures state for a specific hunt so that constructor dependencies can be
  # shared with child dependencies.
  #
  # @example
  #
  #   class Service
  #     depend_on do
  #       options UserOptions
  #     end
  #
  #     def initialize( user )
  #     end
  #   end
  #
  #   class UserOptions
  #
  #     depend_on do
  #       user User
  #     end
  #   end
  #
  #   user    = User.find 123
  #   service = scorpion.fetch Service, user
  #   service.options.user # => user
  class Hunt
    extend Forwardable

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Scorpion] scorpion used to fetch uncaptured dependency.
    attr_reader :scorpion

    # @!attribute
    # @return [Array<Array>] the stack of trips conducted by the hunt to help
    #   resolve child dependencies.
    attr_reader :trips
    private :trips

    # @!attribute
    # @return [Trip] the current hunting trip.
    attr_reader :trip
    private :trip

    delegate %i[contract arguments args kwargs block] => :trip

    # @!attribute contract
    # @return [Class,Module,Symbol] contract being hunted for.

    # @!attribute [r] arguments
    # @return [Array<Object>] positional arguments to pass to the initializer of {#contract} when found.

    # @!attribute block
    # @return [#call] block to pass to constructor of contract when found.

    #
    # @!endgroup Attributes

    ruby2_keywords def initialize(scorpion, contract, *arguments, &block)
      @scorpion  = scorpion
      @trips     = []
      @trip      = Trip.new(contract, arguments, block)
    end

    # Hunt for additional dependency to satisfy the main hunt's contract.
    # @see Scorpion#hunt
    ruby2_keywords def fetch(contract, *arguments, &block)
      push(contract, arguments, block)
      execute
    ensure
      pop
    end

    # Inject given `object` with its expected dependencies.
    # @param [Scorpion::Object] object to be injected.
    # @return [Scorpion::Object] the injected object.
    def inject(object)
      trip.object = object
      object.send(:scorpion_hunt=, self)

      object.injected_attributes.each do |attr|
        next if object.send("#{attr.name}?")
        next if attr.lazy?

        object.send(:inject_dependency, attr, fetch(attr.contract))
      end

      object.send(:on_injected)

      object
    end

    # Allow the hunt to spawn objects.
    # @see Scorpion#spawn
    ruby2_keywords def spawn(klass, *arguments, &block)
      scorpion.spawn(self, klass, *arguments, &block)
    end
    alias new spawn

    private

      def execute
        execute_from_trips || execute_from_scorpion
      end

      def execute_from_trips
        trips.each do |trip|
          if resolved = execute_from_trip(trip)
            return resolved
          end
        end

        nil
      end

      def execute_from_trip(trip)
        return unless obj = trip.object
        return obj if contract === obj

        # If we have already resolved an instance of this contract in this
        # hunt, then return that same object.
        if obj.is_a?(Scorpion::Object)
          obj.injected_attributes.each do |attr|
            next unless attr.contract == contract

            return obj.send(attr.name) if obj.send(:"#{attr.name}?")
          end
        end

        nil
      end

      def execute_from_scorpion
        scorpion.execute(self)
      end

      def push(contract, arguments, block)
        trips.push(trip)

        @trip = Trip.new(contract, arguments, block)
      end

      def pop
        @trip = trips.pop
      end

      class Trip
        attr_reader :contract
        attr_reader :arguments
        attr_reader :block

        attr_accessor :object

        def initialize(contract, arguments, block)
          @contract     = contract
          @arguments    = arguments
          @block        = block
        end
      end

      class InitializerTrip < Trip; end
  end
end
