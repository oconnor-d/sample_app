require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user) 
    get root_path
  end

  test "valid micropost submission" do
    assert_select 'div.pagination'

    content = "This micropost really ties the room together"

    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end

    assert_redirected_to root_url
    
    follow_redirect!

    assert_match content, response.body
  end

  test "invalid micropost submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end

    assert_select 'div#error_explanation'
  end
  
  test "successfully delete a micropost" do
    assert_select 'a', text: 'delete'

    first_micropost = @user.microposts.paginate(page: 1).first

    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "no delete links for different user's microposts" do
    get user_path(users(:archer))

    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    # Multiple posts
    assert_match "#{@user.microposts.count} microposts", response.body

    # No posts
    other_user = users(:lurker)
    log_in_as(other_user)
    get root_path

    assert_match '0 microposts', response.body

    # One post
    other_user.microposts.create!(content: "A micropost!")
    get root_path

    assert_match '1 micropost', response.body
  end
end
