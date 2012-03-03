# -*- coding: utf-8 -*-
class Alice::CommentableDecorator < Alice::BaseDecorator

  def form_position?
    :below
  end

  def replies_class
    'alice-comments'
  end

  def show_new_above
    show_new if form_position? == :above
  end

  def show_new_below
    show_new if form_position? == :below
  end

  def subject
    to_model.respond_to?(:resubject) ? to_model.resubject : "Re: #{to_model}"
  end

  def ident
    :comments
  end

  def commentable_decorator
    self
  end

  def resource_decorator
    self
  end

  def show_header
    h.content_tag :h2, comments_title.html_safe, :class=>'alice-header'
  end

  def show_replies
    return '' unless to_model
    h.content_tag :div, :id=>'comments' do
      show_header + show_new_above + super + show_new_below
    end
  end

  def comments_title
    "Комментарии (<span id='alice-comments-counter'>#{to_model.total_comments_count}</span>)"
  end

end
