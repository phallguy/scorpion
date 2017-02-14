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


    context "inheritance" do
      let( :klass ) do
        Class.new do
          include Scorpion::Object

          initialize label: String do |label:|
            @label = label.reverse
          end
        end
      end

      let( :derived ) do
        Class.new( klass )
      end

      it "inherits super initializer block" do
        expect( derived.new( label: "Super" ).label ).to eq "repuS"
      end

      it "inherits initializer_injections" do
        expect( klass.initializer_injections.count ).to eq 1
        expect( klass.initializer_injections ).to eq derived.initializer_injections
      end

      it "can override initializer_injections" do
        more_derived = Class.new( derived ) do
          initialize do
          end
        end

        expect( more_derived.initializer_injections.count ).to eq 0
      end

      it "fails if changing attribute without changing initializer" do
        expect do
          overriden = Class.new( klass ) do
            attr_dependency :label, Integer
          end
        end.to raise_exception Scorpion::ContractMismatchError
      end

      it "works if changing attribute and changing initializer" do
        expect do
          overriden = Class.new( klass ) do

            initialize label: Integer
            attr_dependency :label, Integer
          end
        end.not_to raise_exception
      end

    end

end