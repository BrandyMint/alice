require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  test "test app is here" do
    assert_kind_of Dummy::Application, Rails.application
  end

end

