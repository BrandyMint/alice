class Comment < ActiveRecord::Base
  attr_accessible :all_comments_count, :author_id, :commentable_id, :commentable_type, :comments_count, :resource_id, :resource_type, :text
end
