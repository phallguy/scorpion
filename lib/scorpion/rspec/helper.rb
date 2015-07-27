module Scorpion
  module Rspec
    module Helper

      def self.included( base )
        base.let( :scorpion ){ Scorpion::Rspec.scorpion_nest.conceive }
        base.send :extend, Scorpion::Rspec::Helper::Methods

        super
      end


      module Methods

        def scorpion( &block )
          before( :each ) do
            scorpion.prepare &block
          end
        end

      end

    end
  end
end
