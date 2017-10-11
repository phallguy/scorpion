module Scorpion
  module Rspec
    module Helper

      def self.included( base )
        base.let( :scorpion ) { Scorpion::Rspec.scorpion_nest.conceive }
        base.send :extend, Scorpion::Rspec::Helper::Methods


        base.infest_nest ActionController::Base if defined? ActionController::Base
        base.infest_nest ActiveJob::Base        if defined? ActiveJob::Base
        base.infest_nest ActionMailer::Base     if defined? ActionMailer::Base

        super
      end


      module Methods

        # Intercept calls to conceive_scorpion in classes that include
        # {Scorpion::Rails::Nest}
        # @param [Class] klass that includes {Scorpion::Rails::Nest}
        # @return [void]
        def infest_nest( klass )
          return unless klass < Scorpion::Rails::Nest

          before( :each ) do
            allow_any_instance_of( klass ).to receive( :conceive_scorpion )
              .and_wrap_original do |m|
                # When hunting for dependencies in controllers, jobs, etc. first
                # consider the dependencies defined in the specs.
                Scorpion::ChainHunter.new( scorpion, m.call )
              end
          end
        end

        # Set up scorpion hunting rules for the spec.
        def scorpion( &block )
          before( :each ) do
            scorpion.prepare &block
          end
        end

        # Specify a specific hunting contract and prepare a `let` block of the
        # same name.
        def hunt( name, contract, value = :unspecified, &block )
          block ||= -> { value == :unspecified ? instance_double( contract ) : value }

          let( name, &block )

          before( :each ) do
            scorpion.prepare do |hunter|
              if value == :unspecified
                hunter.hunt_for contract do
                  send( name )
                end
              else
                hunter.hunt_for contract, return: value
              end
            end
          end
        end

        def hunt!( name, contract, value = :unspecified, &block )
          hunt name, contract, value, &block
          before(:each) { send name }
        end

        # Captures an instance of the given `contract` and assigns it to `name`
        # and return the same instance when the scorpion resovles any instance
        # of the contract.
        # @param [Symbol] name of the rspec method to assign.
        # @param [Module] contract to hunt for.
        def capture( name, contract )
          hunt( name, contract ) do
            scorpion.new contract
          end
        end

        # Captures an instance of the given `contract` and assigns it to `name`
        # and return the same instance when the scorpion resovles any instance
        # of the contract.
        # @param [Symbol] name of the rspec method to assign.
        # @param [Module] contract to hunt for.
        def capture!( name, contract )
          hunt!( name, contract ) do
            scorpion.new contract
          end
        end

      end

    end
  end
end
