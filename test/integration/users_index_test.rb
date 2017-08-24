require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@admin)

    get users_path

    assert_template 'users/index'
    assert_select 'div.pagination', count: 2

    User.paginate(page: 1).each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
      end
    end
  end

  test "index as admin" do
    log_in_as(@admin)

    get users_path

    User.paginate(page: 1).each do |user|
      unless user == @admin
        if user.activated?
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)

    get users_path

    assert_select 'a', text: 'delete', count: 0
  end
end
