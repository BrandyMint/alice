# -*- coding: utf-8 -*-
module Alice
  module ApplicationHelper

    def link_to_comments(commentable)
      link_to "Комментарии (#{commentable.comments_count})", polymorphic_path(commentable, :anchor=>'comments'), :class=>'alice-link-to-comments'
    end

  end
end
