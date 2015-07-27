require 'scorpion'

module Scorpion
  module Rspec
    require 'scorpion/rspec/helper'

    def self.scorpion_nest
      @scorpion ||= Scorpion::Nest.new
    end

    # Prepare a root scorpion for testing.
    def self.prepare( &block )
      scorpion_nest.prepare &block
    end

  end
end