module Scorpion
  module Scorpions
    class Simple
      include Scorpion

      def hunt!( attribute, object = nil )
        spawn attribute.contract
      end

    end
  end
end