module Alice
  module Migration

    def create_comments_table(table_name=:comments)
    create_table table_name do |t|

      t.integer :commentable_id, :null=>false
      t.string  :commentable_type, :null=>false
      t.text    :content
      t.integer :author_id
      t.boolean :is_removed, :null=>false, :default=>false
      t.string  :author_ip
      t.string  :author_email
      t.string  :author_name
      t.integer :resource_id, :null=>false
      t.string  :resource_type, :null=>false
      t.integer "#{table_name}_count", :null=>false, :default=>0
      t.integer "total_#{table_name}_count", :null=>false, :default=>0

      t.timestamps

      yield(t) if block_given?
    end

    add_index table_name, [:commentable_type, :commentable_id, :id], :name=>"#{table_name}_commentable"
    add_index table_name, [:resource_type, :resource_id], :name=>"#{table_name}_resource"
    end
  end
end
