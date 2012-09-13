class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :text
      t.integer :author_id
      t.integer :resource_id
      t.string :resource_type
      t.integer :comments_count
      t.integer :all_comments_count

      t.timestamps
    end
  end
end
