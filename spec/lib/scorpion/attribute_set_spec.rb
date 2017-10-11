require "spec_helper"

describe Scorpion::AttributeSet do
  let( :set ) { Scorpion::AttributeSet.new }

  it "yields attributes" do
    set.define do
     apples "apples"
    end
    expect( set.first ).to be_a Scorpion::Attribute
  end

  describe "#define" do
    it "yields itself when arg expected" do
      set.define do |itself|
        expect( set ).to be itself
      end
    end

    it "yields self as context when no arg expeted" do
      expect( set ).to receive( :define_attribute )
      set.define do
        whatever Scorpion
      end
    end
  end

  describe "define_attribute" do
    it "adds an expected attribute" do
      set.define do
        logger nil
      end

      expect( set[:logger] ).not_to be_lazy
    end

    it "adds an allowed attribute" do
      set.define do
        logger nil, lazy: true
      end

      expect( set[:logger] ).to be_lazy
    end

    it "parses traits" do
      set.define do
        with_traits nil, :color
      end

      expect( set[:with_traits].traits ).to eq [:color]
    end

    it "parses traits and options" do
      set.define do
        both nil, :formatted, lazy: true
      end

      expect( set[:both] ).to be_formatted
      expect( set[:both] ).to be_lazy
    end


    it "parses options" do
      set.define do
        options nil, lazy: true
      end

      expect( set[:options] ).to be_lazy
    end
  end

  describe "#merge" do
    it "merges two sets" do
      a = Scorpion::AttributeSet.new.define do
        alpha nil
      end

      b = Scorpion::AttributeSet.new.define do
        beta nil
      end

      c = a | b

      expect( c ).to be_key :alpha
      expect( c ).to be_key :beta
    end
  end

end