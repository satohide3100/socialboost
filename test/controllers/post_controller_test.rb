require 'test_helper'

class PostControllerTest < ActionDispatch::IntegrationTest
  test "should get bulk" do
    get post_bulk_url
    assert_response :success
  end

end
