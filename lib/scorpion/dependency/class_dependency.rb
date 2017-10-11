require "scorpion/dependency"

module Scorpion
  class Dependency
    # {Dependency} for a {Class} contract
    class ClassDependency < Scorpion::Dependency

      def fetch( hunt )
        resolved = resolve_dependencies( hunt )
        hunt.scorpion.spawn hunt, hunt.contract, *hunt.arguments, **resolved, &hunt.block
      end

      private

        def resolve_dependencies( hunt )
          dependencies = hunt.dependencies
          return dependencies unless hunt.contract.respond_to? :initializer_injections

          hunt.contract.initializer_injections.each_with_object(dependencies.dup) do |attr, deps|
            next if attr.lazy?

            deps[attr.name] ||= hunt.fetch_by_traits( attr.contract, attr.traits )
          end
        end

    end
  end
end