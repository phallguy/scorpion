require "scorpion"

module Scorpion
  module Minitest
    private

      def scorpion_nest
        @scorpion_nest ||= Scorpion.instance.build_nest
      end

  end
end
