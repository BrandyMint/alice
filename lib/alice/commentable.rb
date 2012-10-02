module Alice::Commentable
  def be_commentable scope_name=:comments
    extend ClassMethods
    include InstanceMethods

    attr_readonly :comments_count, :total_comments_count

    # Full comments tree
    has_many :total_comments, :as => :resource, :class_name=>'Comment', :dependent => :destroy

    # Direct replies to this object
    has_many :comments, :as => :commentable

    before_destroy :destroy_comments
  end

  module ClassMethods
  end

  module InstanceMethods

    def active_comments_count
       total_comments.active.count
    end

    def increment_total_counter
      self.class.increment_counter(:total_comments_count, self.id)
      self.increment_commentable if self.respond_to? :increment_commentable
    end

    def decrement_total_counter
      self.class.decrement_counter(:total_comments_count, self.id)
      self.decrement_commentable if self.respond_to? :decrement_commentable
    end

    def commentable_resource?
      !(self.attributes.has_key?('resource_type') && self.attributes.has_key?('commentable_type'))
    end

    def destroy_comments
      if commentable_resource?
        self.total_comments.map &:destroy
      else
        self.comments.each do |c|
          if self.commentable == self.resource
            c.destroy
          else
            c.reparent self.commentable
          end
        end
      end
    end
  end
end

