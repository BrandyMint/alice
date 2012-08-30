# -*- coding: utf-8 -*-

module Alice
  class BaseController < ::ApplicationController

    def create
      # authorize_user!
      # TODO authorize! :create, ::Comment
      
      data = get_data :author=>current_user, :author_ip=>request.remote_ip
      
      if data[:content].blank?
        return render :text => "Комментарий не должен быть пустым", :status => '406'
      end
      comment = create_comment data

      if request.xhr?
        response_after_create_as_xhr comment
      else
        response_after_create comment
      end
    end

    def update
      # TODO доступ к аттрибутам
      data = get_data

      comment = comment_class.find(params[:id])

      cd = decorate_comment comment

      comment.update_attributes data, :as => cd.mass_assignment_role if cd.can_update?

      if request.xhr?
        render :inline => cd.comment_body
      else
        redirect_to polymorphic_path(comment.resource, :anchor=>"comment_#{comment.id}")
      end
    end

    def destroy
      comment = comment_class.find(params[:id])
      #c = comment.commentable
      #r = comment.resource

      decorator = commentable_decorator comment.commentable # Alice::CommentableDecorator.new comment.commentable
      cd = decorator.comment_decorated(comment)

      cd.remove if cd.can_destroy?

      if request.xhr?
        render :inline => cd.comment_body
      else
        redirect_to :back #polymorphic_path(r, :anchor=>c.is_a?(Comment) ? "comment_#{c.id}" : "comments")
      end
    end

    private

    def response_after_create_as_xhr comment
      if comment.persisted?
        @decorator = commentable_decorator parent #Alice::CommentableDecorator.new parent
        render :inline => @decorator.comment_decorated(comment).show_comment
      else
        raise 'not implemented'
      end
    end

    def response_after_create comment
      if comment.persisted?
        # TODO Использователь commentable_decorator.url
        redirect_to polymorphic_path(comment.resource, :anchor=>"comment_#{comment.id}")
      else
        respond_with @comment=comment
      end
    end

    def create_comment attrs
      parent_comments.create attrs
    end

    def parent_comments
      parent.send scope_name
    end

    def get_data hash={}
      data = params.key?(params_key) ? params[params_key] : {:content=>params[:content]}

      data.merge hash
    end

    def params_key
      scope_name.to_s.singularize.to_sym
    end

    def scope_name
      :comments
    end

    def comment_class
      scope_name.to_s.classify.constantize
    end

    def parent
      @parent||=find_parent
    end

    def commentable_decorator resource=nil
      resource ||= parent
      # TODO Тут надобы применять находить нужный декоратор
      commentable_decorator_class.new resource
    end

    def commentable_decorator_class
      Alice::CommentableDecorator
    end

    def decorate_comment comment
      decorator = commentable_decorator comment.commentable
      decorator.comment_decorated(comment)
    end


    #  def parent_type
    #    :comment
    #  end
    #
    #  def parent_class
    #    parent_type.to_s.classify
    #  end
    #
    #  def parent_key
    #    parent_class.foreign_key
    #  end
    #
    # def update
    #     @comment = Comment.find(params[:id])
    #     if @comment.update_attributes(params[:comment])
    #       redirect_to @comment, :notice  => "Successfully updated comment."
    #     else
    #       render :action => 'edit'
    #     end
    #   end
    # =end

    #   #Найти объект комментирования(дискуссии, комментарии и т.д.)
    def find_parent
      params.each do |name,value|
        if name =~ /(.+)_id$/
          begin
            return $1.classify.constantize.find(value)
          rescue
          end
        end
      end
      nil
    end
  end
end
