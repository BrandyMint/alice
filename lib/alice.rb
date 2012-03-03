# -*- coding: utf-8 -*-

module Alice
end

require 'alice/action_view_extension'
ActionView::Base.send :include, Alice::ActionViewExtension

require 'alice/commentable'
ActiveRecord::Base.extend Alice::Commentable

require 'alice/comment'
ActiveRecord::Base.extend Alice::Comment

require 'alice/migration'
ActiveRecord::Migration.send :include, Alice::Migration

require 'alice/application_helper'

require 'alice/engine'

