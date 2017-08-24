require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @activated_user     = users(:michael)
    @not_activated_user = users(:nat)
  end

  test "shows the profile page of an activated user" do
    get user_path(@activated_user)

    assert_response :success
  end

  test "does not show the profile page of an unactivated user" do
    get user_path(@not_activated_user)

    assert_redirected_to root_url
  end
end
