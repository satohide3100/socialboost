require 'test_helper'

class UnfollowControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get unfollow_list_url
    assert_response :success
  end

end
