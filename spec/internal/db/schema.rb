ActiveRecord::Schema.define do
  # ActiveRecord::Schema.define do
  create_table( :todos, :force => true ) do |t|
    t.string :name
    t.references :author
    t.timestamps null: false
  end

  create_table( :authors, :force => true ) do |t|
    t.string :name
    t.timestamps null: false
  end

end
