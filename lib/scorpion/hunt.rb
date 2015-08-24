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

      delegate [:contract, :traits, :dependencies, :arguments, :block] => :trip

    # @!attribute contract
    # @return [Class,Module,Symbol] contract being hunted for.

    # @!attribute traits
    # @return [Array<Symbol>] traits being hunted for.

    # @!attribute [r] dependencies
    # @return [Hash<Symbol,Dependency>] hash of dependencies to pass to initializer of {#contract} when found.

    # @!attribute [r] arguments
    # @return [Array<Object>] positional arguments to pass to the initializer of {#contract} when found.

    # @!attribute block
    # @return [#call] block to pass to constructor of contract when found.

    #
    # @!endgroup Attributes

    def initialize( scorpion, contract, traits, *arguments, **dependencies, &block )
      @scorpion  = scorpion
      @trips     = []
      @trip      = Trip.new contract, traits, arguments, dependencies, block
    end

    # Hunt for additional dependency to satisfy the main hunt's contract and traits.
    # @see Scorpion#hunt
    def fetch( contract, *arguments, **dependencies, &block )
      fetch_by_traits( contract, nil, *arguments, **dependencies, &block )
    end

    # Hunt for additional dependency to satisfy the main hunt's contract and traits.
    # @see Scorpion#hunt
    def fetch_by_traits( contract, traits, *arguments, **dependencies, &block )
      push contract, traits, arguments, dependencies, block
      execute
    ensure
      pop
    end

    # Inject given `object` with its expected dependencies.
    # @param [Scorpion::Object] object to be injected.
    # @param [Hash<Symbol,Object>] dependencies explicitly provided.
    # @return [Scorpion::Object] the injected object.
    def inject( object, **dependencies )
      trip.object = object

      dependencies.each do |key,value|
        if attr = object.injected_attributes[key]
          object.send :inject, attr, value
        end
      end

      object.injected_attributes.each do |attr|
        next if object.send "#{ attr.name }?"
        next if attr.lazy?

        object.send :inject, attr, fetch_by_traits( attr.contract, attr.traits )
      end

      object
    end

    # Allow the hunt to spawn objects.
    # @see Scorpion#spawn
    def spawn( klass, *arguments, **dependencies, &block )
      scorpion.spawn( self, klass, *arguments, **dependencies, &block )
    end

    private

      def execute
        execute_from_trips || execute_from_scorpion
      end

      def execute_from_trips
        return if dependencies.any?

        trips.each do |trip|
          return trip.object if contract === trip.object
          trip.dependencies.each do |key,value|
            return value if contract === value
          end
        end

        nil
      end

      def execute_from_scorpion
        scorpion.execute self
      end

      def push( contract, traits, arguments, dependencies, block )
        trips.push trip

        @trip = Trip.new contract, traits, arguments, dependencies, block
      end

      def pop
        @trip = trips.pop
      end

      class Trip
        attr_reader :contract
        attr_reader :traits
        attr_reader :arguments
        attr_reader :dependencies
        attr_reader :block

        attr_accessor :object

        def initialize( contract, traits, arguments, dependencies, block )
          @contract     = contract
          @traits       = traits
          @arguments    = arguments
          @dependencies = dependencies
          @block        = block

          @caller = caller
        end
      end

      class InitializerTrip < Trip; end
  end
end