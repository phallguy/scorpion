class Todo < ActiveRecord::Base

  # @!attribute name
  # @return [String]


  # @!attribute
  # @return [Author] name
    belongs_to :author, inverse_of: :todos, optional: true




end