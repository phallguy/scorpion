require 'spec_helper'

describe Scorpion::ObjectConstructor do
   it 'defined an initializer' do
      klass = Class.new do
        include Scorpion::Object

        initialize logger: String
      end

      expect( klass.instance_method(:initialize).arity ).to eq 1
    end

    it "executes initializer code" do
      expect do |b|
        klass = Class.new do
          include Scorpion::Object

          initialize label: String, &b
        end

        klass.new "home"
      end.to yield_control
    end

    it "creates an initializer that accepts a block" do
      klass = Class.new do
        include Scorpion::Object

        initialize label: String do |label, &block|
          block.call
        end
      end

      expect do |b|
        klass.new "apples", &b
      end.to yield_control
    end

    it "raises ArityMismatch when block does not accept expected number of arguments" do
      expect do
        Class.new do
          include Scorpion::Object

          # Should fail here
          initialize label: String do |&block|
          end
        end

      end.to raise_error Scorpion::ArityMismatch
    end


    it "it defines matching attributes" do
      klass = Class.new do
        include Scorpion::Object

        initialize label: String
      end

      expect( klass.new( "apples" ).label ).to eq "apples"
    end
end