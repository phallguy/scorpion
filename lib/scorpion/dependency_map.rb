module Scorpion
  # {#chart} available {Dependency} and {#find} them based on desired
  # {Scorpion::Attribute attributes}.
  class DependencyMap
    include Enumerable
    extend Forwardable

    # ============================================================================
    # @!group Attributes
    #

    # @return [Scorpion] the scorpion that created the map.
      attr_reader :scorpion

    # @return [Set] the set of dependency charted on this map.
      attr_reader :dependency_set
      private :dependency_set

    # @return [Set] the set of dependencies charted on this map that is shared
    #   with all child dependencies.
      attr_reader :shared_dependency_set
      private :shared_dependency_set

    # @return [Set] the active dependency set either {#dependency_set} or {#shared_dependency_set}
      attr_reader :active_dependency_set
      private :active_dependency_set

    #
    # @!endgroup Attributes

    def initialize( scorpion )
      @scorpion              = scorpion
      reset
    end

    # Find {Dependency} that matches the requested `contract` and `traits`.
    # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
    # @param [Array<Symbol>] traits found on the {Dependency}.
    # @return [Dependency] the dependency matching the attribute.
    def find( contract, traits = nil )
      dependency_set.find{ |p| p.satisfies?( contract, traits ) } ||
      shared_dependency_set.find{ |p| p.satisfies?( contract, traits ) }
    end

    # Chart the {Dependency} that this hunting map can {#find}.
    #
    # The block is executed in the context of DependencyMap if the block does not
    # accept any arguments so that {#hunt_for}, {#capture} and {#share} can be
    # called as methods.
    #
    # @example
    #
    #   cache = {}
    #   chart do
    #     self #=> DependencyMap
    #     hunt_for Repository
    #     capture  Cache, return: cache # => NoMethodError
    #   end
    #
    #   chart do |map|
    #     map.hunt_for Repository
    #     map.capture  Cache, return: cache # => No problem
    #   end
    #
    # @return [self]
    def chart( &block )
      return unless block_given?

      if block.arity == 1
        yield self
      else
        instance_eval &block
      end

      self
    end

    # Define {Dependency} that can be found on this map by `contract` and `traits`.
    #
    # If a block is given, it will be used build the actual instances of the
    # dependency for the {Scorpion}.
    #
    # @param [Class,Module,Symbol] contract describing the desired behavior of the dependency.
    # @param [Array<Symbol>] traits found on the {Dependency}.
    # @return [Dependency] the dependency to be hunted for.
    def hunt_for( contract, traits = nil, &builder )
      active_dependency_set.unshift define_dependency( contract, traits, &builder )
    end

    # Captures a single dependency and returns the same instance fore each request
    # for the resource.
    # @see #hunt_for
    # @return [Dependency] the dependency to be hunted for.
    def capture( contract, traits = nil, &builder )
      active_dependency_set.unshift Dependency::CapturedDependency.new( define_dependency( contract, traits, &builder ) )
    end
    alias_method :singleton, :capture

    # Share dependencies defined within the block with all child scorpions.
    # @return [Dependency] the dependency to be hunted for.
    def share( &block )
      old_set = active_dependency_set
      @active_dependency_set = shared_dependency_set
      yield
    ensure
      @active_dependency_set = old_set
    end

    # @visibility private
    def each( &block )
      dependency_set.each &block
    end
    delegate [ :empty?, :blank?, :present? ] => :dependency_set

    # Replicates the dependency in `other_map` into this map.
    # @param [Scorpion::DependencyMap] other_map to replicate from.
    # @return [self]
    def replicate_from( other_map )
      other_map.each do |dependency|
        if replica = dependency.replicate
          dependency_set << replica
        end
      end

      self
    end

    # Remove all dependency mappings.
    def reset
      @dependency_set.each &:release        if @dependency_set
      @shared_dependency_set.each &:release if @shared_dependency_set

      @dependency_set        = @active_dependency_set = []
      @shared_dependency_set = []
    end

    private

      def define_dependency( contract, traits, &builder )
        Dependency.define contract, traits, &builder
      end
  end
end