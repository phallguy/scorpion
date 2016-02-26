module Scorpion
  module Rack
    class MissingScorpionError < Scorpion::Error

      def initialize( middleware )
        super translate( :rack_missing_scorpion, middleware: middleware )
      end

    end
  end
end