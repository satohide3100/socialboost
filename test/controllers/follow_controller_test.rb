require 'test_helper'

class FollowControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get follow_list_url
    assert_response :success
  end

end
