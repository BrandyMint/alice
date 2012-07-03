# -*- coding: utf-8 -*-
class Alice::CommentDecorator < Alice::BaseDecorator
  decorates :comment

  def default_level
    self.commentable_decorator.level + 1
  end

  def default_context
    commentable_decorator.context
  end

  def default_commentable_decorator
    commentable_decorator_class.new to_model.commentable, inherit_options
  end

  def default_resource_decorator
    if comment.commentable == comment.resource
      commentable_decorator
    else
      resource_decorator_class.new to_model.resource, inherit_options
    end
  end

  def default_show_forms?
    commentable_decorator.show_forms?
  end

  def default_show_replies?
    commentable_decorator.show_replies?
  end

  def is_answer?
    to_model.commentable==to_model.resource and to_model.commentable.is_a?(Question)
  end

  def is_official?
    !!company
  end

  def css_class
    "alice-comment alice-comment-level-#{level} #{is_official? ? 'offical-comment' : ''}"
  end

  def css_id
    "comment_#{id}"
  end

  def comment_body
    h.render 'comments/comment_body', :decorator => self
  end
  def show_comment
    h.render 'comments/comment', :decorator => self
  end

  def show_hidden_edit_form
    return unless show_forms?
    h.render 'comments/edit', :decorator => self, :comment => comment if can_edit?
  end

  def show_time
    if time_as_link?
      h.link_to created_at, url, :class=>'alice-comment-timelink', :title=>'Прямая ссылка', :rel=>:twipsy
    else
      h.content_tag :span, created_at, :class=>'alice-comment-timelink'
    end
  end

  def show_comment_details
    h.content_tag :div, :class=>'alice-comment-details' do
      h.content_tag( :div,
        (author.to_s + show_comment_links.to_s + show_time.to_s).html_safe,
        :class => 'element-details') + rating.to_s
    end
  end

  def can_destroy?
    return nil unless show_forms?
    h.can? :destroy, comment unless is_removed?
  end

  def time_to_edit
    (15.minutes - (Time.zone.now - comment.created_at)).to_i.seconds
  end

  def can_edit?
    return nil unless show_forms?
    active? and current_user == to_model.author and time_to_edit>10
  end

  def can_hide?
    return nil unless show_forms?
    h.can? :hide, comment unless is_removed?
  end

  # Применяется в контроллере
  def can_update?
    h.can?(:hide, comment) or current_user == to_model.author# and time_to_edit>10
  end

  def mass_assignment_role
    h.can?(:hide, comment) ? :admin : :default
  end

  # def comment_url *args
  #   urls.api_comment_url *args
  # end

  def toggle_comment_url
    h.comment_url comment, :comment => { :is_hidden=>!is_hidden? }
  end

  def remove_comment_url
    h.comment_url comment
  end

  def comment_content
    if is_removed?
      h.content_tag :span, :class => 'alice-comment-removed' do
        'Комментарий удален'
      end
    else
      comment.content_html
    end
  end

  def unhide_link
    return unless is_hidden?
    h.content_tag :div, :class=>'alice-comment-hidden' do
      h.link_to 'комментарий скрыт', '#',
        :class => 'comment-show-link',
        :title => 'Кликните чтобы раскрыть',
        :rel => :twipsy
    end

  end

  def show_comment_links
    destroy_link = h.link_to 'уд.', remove_comment_url,
                :confirm => 'Удалить, уверен?',
                 :remote => :true,
                 :id => "alice-remove-link-#{ident}",
                 :method => :delete,
                 :data => { :ident => ident },
                 :class=>'comment-remove-link twipsy',
                 :title=>'Удалить' if can_destroy?

    super_destroy_link = h.link_to 'УД!', 
      h.url_for( :subdomain => 'admin', :only_path=> false, 
                :controller => 'admin/admin_comments', :action => :destroy, :id => comment.id ),
      :title => 'Удалить окончательно',
      :class => 'comment-remove-link twipsy',
      :method => :delete,
      :confirm => 'Удалить окончательно, а вместе с ним и всю ветку ?' if h.can? :manage, :all

    edit_link = h.link_to("ред.", '#', 
                          :class => 'comment-edit-link',
                          :rel => :twipsy,
                          :title => "Редактировать, времени осталось #{time_to_edit} сек." ) if can_edit?

    hide_link = h.link_to(is_hidden? ? "раскр." : "скр.",
                          toggle_comment_url,
                          :method => :put,
                          :class => 'comment-toggle-link twipsy',
                          :remote => true, 
                          :title => is_hidden? ? 'Раскрыть' : 'Скрыть') if can_hide?

    h.content_tag :span, :class=>'alice-comment-actions' do
       (destroy_link.to_s + super_destroy_link.to_s + hide_link.to_s + edit_link.to_s).html_safe
    end
  end

  def subject
    resource_decorator.subject
  end

  def url *args
    resource_decorator.url :anchor=>ident
  end

  def resource_name
    case comment.resource_type
      when 'Post'
        'Публикация'
      when 'Company'
        'Компания'
      when 'NewsItem'
        'Новость'
      else
        ''
    end
  end
end
