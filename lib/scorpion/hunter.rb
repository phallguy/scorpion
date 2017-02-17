module Scorpion
  # A concrete implementation of a Scorpion used to hunt down food for a {Scorpion::Object}.
  # @see Scorpion
  class Hunter
    include Scorpion

    # ============================================================================
    # @!group Attributes
    #

    # @return [Scorpion::DependencyMap] map of {Dependency} and how to create instances.
      attr_reader :dependency_map
      protected :dependency_map

    # @return [Scorpion] parent scorpion to deferr hunting to on missing dependency.
      attr_reader :parent
      private :parent

    #
    # @!endgroup Attributes

    def initialize( parent = nil, &block )
      @parent         = parent
      @dependency_map = Scorpion::DependencyMap.new( self )

      prepare &block if block_given?
    end

    # Prepare the scorpion for hunting.
    # @see DependencyMap#chart
    def prepare( &block )
      dependency_map.chart &block
    end

    # Expose dependency injection definitions as top-level methods.
    [:hunt_for,:capture,:share].each do |delegate|
      define_method delegate do |*args,&block|
        prepare do |hunter|
          hunter.send delegate, *args, &block
        end
      end
    end

    # @see Scorpion#replicate
    def replicate
      replica = self.class.new self
      replica.dependency_map.replicate_from( dependency_map )
      replica
    end

    # @see Scorpion#execute
    def execute( hunt, explicit_only = false )
      dependency   = find_dependency( hunt )
      dependency ||= Dependency.define( hunt.contract ) if hunt.traits.blank? && !explicit_only

      unsuccessful_hunt( hunt.contract, hunt.traits ) unless dependency

      dependency.fetch hunt
    end

    # Find any explicitly defined dependencies that can satisfy the hunt.
    # @param [Hunt] hunt being resolved.
    # @return [Dependency] the matching dependency if found
    def find_dependency( hunt )
      dependency   = dependency_map.find( hunt.contract, hunt.traits )
      dependency ||= parent.find_dependency( hunt ) if parent

      dependency
    end

    # @see Scorpion#reset
    def reset
      dependency_map.reset
    end

    # @return [String]
    def inspect
      dependencies = dependency_map.to_a
      result = "<#{ self.class.name } contracts=#{ dependencies.inspect }"
      result << " parent=#{ parent.inspect }" if parent
      result << ">"
      result
    end

  end
end