class AddTotalCommentCountToArtice < ActiveRecord::Migration
  def change
    add_column :articles, :total_comments_count, :integer
  end
end
