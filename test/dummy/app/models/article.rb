class Article < ActiveRecord::Base
  attr_accessible :title
  be_commentable
end
