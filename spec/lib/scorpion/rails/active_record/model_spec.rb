require "spec_helper"

describe Scorpion::Rails::ActiveRecord::Model, type: :model do
  include Scorpion::Rspec::Helper

  before( :each ) do
    author = Author.create! name: "Pitbull"
    Todo.create! name: "Be even more awesome", author: author
  end

  it "shares scorpion with associations" do
    author = Author.with_scorpion( scorpion ).first
    expect( author.todos.scorpion ).to be scorpion
  end

  it "shares scorpion with single associations" do
    todo = Todo.with_scorpion( scorpion ).first
    expect( todo.author.scorpion ).to be scorpion
  end

  it "shares scorpion with custom scope" do
    expect( Author.with_scorpion( scorpion ).named( "Pitbull" ).scorpion ).to be scorpion
  end

  it "shares scorpion with custom scope results" do
    expect( Author.with_scorpion( scorpion ).named( "Pitbull" ).first.scorpion ).to be scorpion
  end

  it "shares scorpion with custom scope extension results" do
    expect( Author.with_scorpion( scorpion ).named( "Pitbull" ).alphabetical.first.scorpion ).to be scorpion
  end

end
