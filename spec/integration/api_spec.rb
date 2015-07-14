require 'spec_helper'



describe "Using Scorpion" do

  before :each do

    module Test
      class UserService
        extend Scorpion::Injection

        injected :logger, Test::Logger

        def update( user )
          logger.write "Updated user #{ user }"
        end
      end

      class Compiler
        injected :logger, Test::Logger

        def compile
          logger.write "Compiling with #{ self.class.name }"
        end
      end

      class PhpCompiler
      end

      class UniversalCompiler
      end
    end

    class Stung
      extend Scorpion::King

      inject :user do |scorpion|
        expect :user_service, Test::UserService
        expect :compiler, Test::Compiler, :php
        accept_block
      end

      injected :logger, Test::Logger, :remote

      def work
        compiler.compile
        user_service.update( user )
        logger.write "Did it"
      end
    end
  end

  let( :nest ) do
    Scorpion::King.new do
      use Test::Compiler do
        trait :php, PhpCompiler
      end
    end
  end

  it "works" do
    stung = nest.with_scorpion do
      Stung.new "harry"
    end
    stung.work
  end

end