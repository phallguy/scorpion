require 'spec_helper'
require 'scorpion/rails'

describe Scorpion::Rails::ActiveRecord::Relation, type: :model do
  include Scorpion::Rspec::Helper

  let( :criteria ) { Todo.with_scorpion( scorpion ) }

  it "shares scorpion with fetched records" do
    Todo.create! name: "Be awesome"

    expect( criteria.first.scorpion ).to eq scorpion
  end

  it "shares scorpion with chained relations" do
    expect( criteria.where( name: "" ).scorpion ).to be scorpion
  end

  it "shares scorpion with new records" do
    expect( criteria.new.scorpion ).to be scorpion
    expect( criteria.build.scorpion ).to be scorpion
  end

  it "shares scorpion with new records builder block" do
    criteria.new do |todo|
      expect( todo.scorpion ).to be scorpion
    end
  end

  it "shares scorpion with created records" do
    expect( criteria.create.scorpion ).to be scorpion
  end

  it "shares scorpion with created records builder block" do
    criteria.create do |todo|
      expect( todo.scorpion ).to be scorpion
    end
  end

  it "shares scorpion with created! records" do
    expect( criteria.create!.scorpion ).to be scorpion
  end

  it "shares scorpion with created! records builder block" do
    criteria.create! do |todo|
      expect( todo.scorpion ).to be scorpion
    end
  end

  context "find methods" do
    let!( :todo ){ Todo.create! name: "Bill" }

    it "shares scorpion with found records" do
      expect( criteria.find( todo.id ).scorpion ).to be scorpion
    end

    it "shares scorpion with find_by records" do
      expect( criteria.find_by( name: "Bill" ).scorpion ).to be scorpion
    end

    it "shares scorpion with first record" do
      expect( criteria.first.scorpion ).to be scorpion
    end

    it "shares scorpion with enumerated records" do
      criteria.each do |todo|
        expect( todo.scorpion ).to be scorpion
      end
    end
  end

end