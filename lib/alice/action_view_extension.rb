require 'action_view'

module Alice
  module ActionViewExtension

    # Отсюда все ушло в Alice::ApplicationHelper
    # обидно, потому что хелпер приходится подключать в приложенском application_helper
    # потому что методы определенный тут видны из вьюх приложения и не видны во вьюхах
    # комментатора.
    #
    #
    # Отображаем комментарии во вьюхах, так:
    #
    #   comments @post    # Автоматически покажет все комментарии @post.comments
    #   comments @post, :moderator_comments   # @post.moderator_comments
    #
    #def link_to_comments(commentable)
    #  title = commentable.all_comments_count>0 ? "Обсуждение (#{commentable.all_comments_count}).." : 'Обсуждение..'
    #  link_to title, polymorphic_path(commentable, :anchor=>'comments'), :class=>'comments-link'
    #end
  end
end
