# -*- coding: utf-8 -*-
class Alice::BaseDecorator < ApplicationDecorator

  PARAMETERS = [
    :context, :commentable_decorator, :resource_decorator, :level,
    :order,
    :show_forms?, :show_replies?, :time_as_link?
  ]

  # Для каждого параметра создаем акцессоры,
  # в случае если параметр не определен - пробуем вытащить его дефолтное
  # значение по методу default_PARAMETER
  #
  def self.define_parameter p
    default_meth = "default_#{p}"
    key = p.to_s.gsub('?','').to_sym

    define_method p do
      if self.options.has_key? key
        self.options[key]
      elsif respond_to? default_meth
        send default_meth
      else
        nil
      end
    end

    define_method "#{key}=" do |value|
      self.options[key] = value
    end
  end

  PARAMETERS.each { |p| define_parameter p }

  def default_show_forms?() true; end
  def default_show_replies?() true; end
  def default_order(); :id; end

  def initialize input, o={}
    # В опциях ключи храним как :show_form вместо :show_forms?
    #
    PARAMETERS.each do |p|
      k = p.to_s.gsub('?','').to_sym
      o[k] = o.delete p if o.has_key? p
    end

    super input, o
  end

  def default_level; 0 end
  def commentable_decorator_class; Alice::CommentableDecorator end
  def resource_decorator_class; commentable_decorator_class end
  def comment_decorator_class; Alice::CommentDecorator end
  def new_comment_title; 'Ваш комментарий:' end
  def answers_title; 'комментарии' end
  def css_prefix; 'alice-' end

   def prefix( css )
     css_prefix + css
   end

  def created_at
    if options[:email]
      I18n.l to_model.created_at, :format => :human
    else
      to_model.created_at.to_s :comment
    end
  end

  def author size = true
    size = :medium if size == true
    if to_model.respond_to?(:company) and to_model.company
      if size
        h.show_avatar(to_model.author, :size=>size, :class=>'element-user-avatar') +
          "&nbsp;Официальный комментарий #{h.show_company(company)}".html_safe
      else
        "Официальный комментарий #{h.show_company(company)}".html_safe
      end
    elsif to_model.author
      h.show_user to_model.author, :size=>size
    else
      h.show_anonym (author_name || 'Аноним'), :size=>size, :email => author_email
    end
  end

  def render template, args = {}
    args[:decorator] = self
    h.render template, args
  end

  def reply_link
    h.link_to 'комментировать', '#',
      :class=>'alice-comment-reply_link',
      :id=>"alice-comment-reply_link-#{ident}",
      'data-commentable' => ident unless is_removed? and show_forms?
  end

  def show_below_details
    return '' unless to_model.active?
    h.content_tag :div, :class=>'alice-comment-below' do
      reply_link
      # .alice-comment-reply
      #   - if not decorator.show_replies? and decorator.comments_count>0
      #     %span.alice-comment-comments-count (ответов #{decorator.comments_count})
    end
  end

  def inherit_options o={}
    self.options.slice(:view_context).merge(o)
  end

  def comment_decorated comment, o={}
    comment_decorator_class.new comment, inherit_options(o).merge( :comentable_decorator=>self )
  end

  def replies_class
    'alice-replies'
  end

  def replies_classes
    "alice-level-#{level} #{replies_class} alice"
  end

  def show_replies(level = 0)
    self.level = level
    return unless show_replies?
    h.content_tag :ul, :class => replies_classes, :id => replies_id  do
      replies(level) if replies_count>0
    end
  end

  def replies_count
    comments_count
  end

  def replies(level = 0)
    result = ''
    scope.each do |comment|
      result << comment_decorated(comment).show_comment(level)
    end
    result.html_safe
  end

  def form_url
    h.polymorphic_url(form_object)
  end

  def current_user
    self.options[:current_user] || h.respond_to?( :current_user ) ? h.current_user : nil
  end

  def comments_url
    url :anchor=>:comments # ident
  end

  def answers_link
    # TODO show_ansers_link_if_nont
    return '' unless to_model.total_comments_count>0 and not show_replies?
    h.link_to "#{answers_title} (#{total_comments_count})",
      comments_url,
        :class=>'alice-answers-link'
  end

  def reply_class
    is_comment? ? 'alice-new_form alice-reply_form' : 'alice-new_form'
  end

  def show_real_form
    h.render 'comments/form', decorator: self, current_user: current_user
  end

  def show_form css_class
    h.content_tag :div, :class => css_class do
      if h.can? :create, :comments
        show_real_form
      else
        'Вам запрещено оставлять комментарии'
      end
    end
  end

  def show_reply
    return unless show_forms?
    show_form 'alice-reply-form-block'
  end

  def show_new
    return unless show_forms?
    if new_comment_title
      h.content_tag( :h3, new_comment_title, :class=>'alice-new-header') +
        show_form('alice-new-form-block')
    else
      show_form('alice-new-form-block')
    end
  end

  def ident
    "#{to_model.class.to_s.underscore}_#{to_model.id}"
  end

  def replies_id
    "alice-replies_of-#{ident}"
  end

  def is_comment?
    respond_to? :comment
  end

  def new_reply_placement
    :append
  end

  def form_container_class
    is_comment? ? 'alice-form-container alice-reply_form-container' : 'alice-form-container'
  end

  def form_container_id
    "alice-form-container-#{ident}"
  end

  def form_html
    {
      :class       => "alice-form #{reply_class}",
      :id          => "alice-form-#{ident}",
      :data        => { :commentable => ident,
                        :type        => 'html',
                        :new_reply_placement   => new_reply_placement
      }
    }
  end

  def form_remote
    !!current_user
  end

  def form_object
    if helpers.request.subdomain == 'moderator'
      ['moderator', to_model, build_comment]
    else
      [to_model, build_comment]
    end
  end

  def scope
    to_model.comments.order self.order
  end

  def build_comment
    to_model.comments.build
  end

  def rating
    h.render_cell :voting, :show, to_model
  end


  # Можно ли оставлять официальные комментарии
  #
  def use_official?
    to_model.is_a?(Question) and current_user and current_user.official_companies.present?
  end

  # Опции для селекта выбора компаний
  #
  def official_companies_for_select
    list = current_user.official_companies.map { |c| [c.name, c.id] }
    list.unshift ['нет, личный ответ', nil]
  end

end
