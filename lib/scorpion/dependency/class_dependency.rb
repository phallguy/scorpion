require 'scorpion/dependency'

module Scorpion
  class Dependency
    # {Dependency} for a {Class} contract
    class ClassDependency < Scorpion::Dependency

      def fetch( hunt )
        resolved = *resolve_arguments( hunt )
        hunt.scorpion.spawn hunt, hunt.contract, *resolved, &hunt.block
      end

      private

        def resolve_arguments( hunt )
          arguments = hunt.arguments
          return arguments unless arguments.blank? && hunt.contract < Scorpion::Object

          hunt.contract.initializer_injections.each_with_object([]) do |attr,args|
            next if attr.lazy?

            args << hunt.fetch_by_traits( attr.contract, attr.traits )
          end
        end

    end
  end
end