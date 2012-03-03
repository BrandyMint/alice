module Alice
  module Comment

    def be_comment
      # extend ClassMethods
      include InstanceMethods
      be_commentable table_name

      attr_accessible :content, :commentable_id, :commentable_type, :author, :resource_id, :resource_type, :author_email, :author_name, :author_ip

      belongs_to :commentable, :polymorphic => true, :counter_cache=>"#{table_name}_count"
      belongs_to :resource, :polymorphic => true, :counter_cache=>"total_#{table_name}_count"
      belongs_to :author, :class_name => "User"

      default_scope includes(:author)

      scope :ordered, order('id')

      before_validation do
        self.resource ||= commentable.is_a?(self.class) ? commentable.resource : commentable
      end

      after_create  :increment_commentable
      after_destroy :decrement_commentable

      validates_presence_of :commentable, :content, :resource
      validates_presence_of :author_email, :unless => Proc.new { |c| c.author.present? }
      validates_presence_of :author, :if => Proc.new { |c| c.author_name.blank? and c.author_email.blank? }
    end

    module InstanceMethods

      def reparent new_commentable
        update_attribute :commentable, new_commentable
      end

      def remove
        update_attribute :is_removed, true
      end

      def increment_commentable
        commentable.increment_total_counter unless commentable==resource
      end

      def decrement_commentable
        commentable.decrement_total_counter unless commentable==resource
      end
    end
  end
end
