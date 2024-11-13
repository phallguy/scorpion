require "spec_helper"

describe Scorpion::Rails::ActiveRecord::Association, type: :model do
  include Scorpion::Rspec::Helper

  before(:each) do
    author = Author.create!(name: "Pitbull")
    Todo.create!(name: "Be even more awesome", author: author)
  end

  it "shares scorpion with associations" do
    author = Author.with_scorpion(scorpion).first
    expect(author.todos.scorpion).to(be(scorpion))
  end

  it "shares scorpion with association results" do
    author = Author.with_scorpion(scorpion).first
    expect(author.todos.first.scorpion).to(be(scorpion))
  end

  it "shares scorpion with single associations" do
    todo = Todo.with_scorpion(scorpion).first
    expect(todo.author.scorpion).to(be(scorpion))
  end
end
