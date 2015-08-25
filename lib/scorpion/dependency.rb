module Scorpion
  # Dependency that can be injected into a {Scorpion::Object} by a {Scorpion}.
  class Dependency

    require 'scorpion/dependency/captured_dependency'
    require 'scorpion/dependency/class_dependency'
    require 'scorpion/dependency/module_dependency'
    require 'scorpion/dependency/builder_dependency'
    require 'scorpion/dependency/argument_dependency'

    # ============================================================================
    # @!group Attributes
    #

    # @!attribute
    # @return [Class,Module,Symbol] contract describing the desired behavior of the dependency.
      attr_reader :contract

    # @!attribute
    # @return [Array<Symbol>] the traits available on the dependency.
      attr_reader :traits

    #
    # @!endgroup Attributes

    def initialize( contract, traits = nil )
      @contract = contract
      @traits   = Set.new( Array( traits ) )
    end

    # @return [Boolean] if the dependency satisfies the required contract and traits.
    def satisfies?( contract, traits = nil )
      satisfies_contract?( contract ) && satisfies_traits?( traits )
    end

    # Fetch an instance of the dependency.
    # @param [Hunt] the hunting context.
    # @return [Object] the hunted dependency.
    def fetch( hunt )
      fail "Not Implemented"
    end

    # Release the dependency, freeing up any long held resources.
    def release
    end

    # Replicate the Dependency.
    # @return [Dependency] a replication of the dependency.
    def replicate
      dup
    end

    def ==( other )
      return unless other
      self.class == other.class &&
      contract   == other.contract &&
      traits     == other.traits
    end
    alias_method :eql?, :==

    def hash
      self.class.hash ^
      contract.hash ^
      traits.hash
    end

    private

      # @return [Boolean] true if the pray satisfies the given contract.
      def satisfies_contract?( contract )
        if self.contract.is_a? Symbol
          self.contract == contract
        else
          self.contract <= contract
        end
      end

      # @return [Boolean] true if the pray satisfies the given contract.
      def satisfies_traits?( traits )
        return true if traits.blank?

        Array( traits ).all? do |trait|
          case trait
          when Symbol then self.traits.include? trait
          when Module then self.contract <= trait
          else fail ArgumentError, "Unsupported trait"
          end
        end
      end

    class << self

      # Define dependency based on the desired contract and traits.
      # @return [Dependency] the defined dependency.
      def define( contract, traits = nil, &builder )
        options, traits = extract_options!( traits )

        if options.key?( :return )
          Scorpion::Dependency::BuilderDependency.new( contract, traits ) do
            options[:return]
          end
        elsif with = options[:with]
          Scorpion::Dependency::BuilderDependency.new( contract, traits, with )
        elsif block_given?
          Scorpion::Dependency::BuilderDependency.new( contract, traits, builder )
        elsif contract.respond_to?( :create )
          Scorpion::Dependency::BuilderDependency.new( contract, traits ) do |scorpion,*args,&block|
            contract.create scorpion, *args, &block
          end
        else
          dependency_class( contract ).new( contract, traits, &builder )
        end
      end

      private
        def extract_options!( traits )
          case traits
          when Hash then return [ traits, nil ]
          when Array then
            if traits.last.is_a? Hash
              return [ traits.pop, traits ]
            end
          end

          [ {}, traits]
        end

        def dependency_class( contract, &builder )
          return Scorpion::Dependency::ClassDependency   if contract.is_a? Class
          return Scorpion::Dependency::ModuleDependency  if contract.is_a? Module

          raise Scorpion::BuilderRequiredError
        end
    end

  end
end