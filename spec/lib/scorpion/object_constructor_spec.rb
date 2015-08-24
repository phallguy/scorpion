require 'spec_helper'

describe Scorpion::ObjectConstructor do

   it 'defines an initializer' do
      klass = Class.new do
        include Scorpion::Object

        initialize logger: String
      end

      expect( klass.instance_method(:initialize).arity ).to eq -1
    end

    it "executes initializer code" do
      expect do |b|
        klass = Class.new do
          include Scorpion::Object

          initialize label: String, &b
        end

        klass.new label: "home"
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
        klass.new label: "apples", &b
      end.to yield_control
    end

    it "it defines matching attributes" do
      klass = Class.new do
        include Scorpion::Object

        initialize label: String
      end

      expect( klass.new( label: "apples" ).label ).to eq "apples"
    end

    it "invokes all initializers" do
      klass = Class.new do
        include Scorpion::Object

        initialize label: String do |label:|
          @label = label.reverse
        end
      end

      derived = Class.new( klass ) do
        initialize logger: Logger do |logger:|
          @logger = logger.to_s.reverse.to_sym
        end
      end

      expect( derived.new( logger: :unset, label: "Super" ).label ).to eq "repuS"
      expect( derived.new( logger: :unset, label: "Super" ).logger ).to eq :tesnu
    end

end