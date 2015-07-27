class Author < ActiveRecord::Base

  # @!attribute name
  # @return [String]


  # @!attribute
  # @return [ActiveRecord::Relation<Todo>]
    has_many :todos, inverse_of: :author

  scope :named, ->( name ) { where( name: name ) } do
    def alphabetical
      order( :name )
    end
  end

end