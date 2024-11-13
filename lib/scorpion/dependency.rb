module Scorpion
  # Dependency that can be injected into a {Scorpion::Object} by a {Scorpion}.
  class Dependency
    require "scorpion/dependency/captured_dependency"
    require "scorpion/dependency/class_dependency"
    require "scorpion/dependency/module_dependency"
    require "scorpion/dependency/builder_dependency"
    require "scorpion/dependency/argument_dependency"

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Class,Module,Symbol] contract describing the desired behavior of the dependency.
    attr_reader :contract

    #
    # @!endgroup Attributes

    def initialize(contract)
      @contract = contract
    end

    # @return [Boolean] if the dependency satisfies the required contract.
    def satisfies?(contract)
      satisfies_contract?(contract)
    end

    # Fetch an instance of the dependency.
    # @param [Hunt] the hunting context.
    # @return [Object] the hunted dependency.
    def fetch(_hunt)
      raise("Not Implemented")
    end

    # Release the dependency, freeing up any long held resources.
    def release; end

    # Replicate the Dependency.
    # @return [Dependency] a replication of the dependency.
    def replicate
      dup
    end

    def ==(other)
      return unless other

      self.class == other.class && contract == other.contract
    end
    alias eql? ==

    def hash
      self.class.hash ^ contract.hash
    end

    def inspect
      result = "<#{contract.inspect}"
      result << ">"
      result
    end

    private

      # @return [Boolean] true if the pray satisfies the given contract.
      def satisfies_contract?(contract)
        if self.contract.is_a?(Symbol) || contract.is_a?(Symbol)
          self.contract == contract
        else
          self.contract <= contract
        end
      end

      class << self
        # Define dependency based on the desired contract.
        # @return [Dependency] the defined dependency.
        def define(contract, options = {}, &builder)
          if options.key?(:return)
            Scorpion::Dependency::BuilderDependency.new(contract) do
              options[:return]
            end
          elsif with = options[:with]
            Scorpion::Dependency::BuilderDependency.new(contract, with)
          elsif block_given?
            Scorpion::Dependency::BuilderDependency.new(contract, builder)

          # Allow a Class/Module to define a #create method that will resolve
          # and return an instance of itself. Do not automatically inherit the
          # #create method so only consider it if the owner of the method is the
          # contract itself.
          elsif contract.respond_to?(:create) && contract.singleton_methods(false).include?(:create)
            Scorpion::Dependency::BuilderDependency.new(contract) do |hunt, *args, &block|
              contract.create(hunt, *args, &block)
            end
          else
            dependency_class(contract).new(contract, &builder)
          end
        end

        private

          def dependency_class(contract)
            return Scorpion::Dependency::ClassDependency   if contract.is_a?(Class)
            return Scorpion::Dependency::ModuleDependency  if contract.is_a?(Module)

            raise Scorpion::BuilderRequiredError
          end
      end
  end
end
