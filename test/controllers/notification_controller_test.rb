require 'test_helper'

class NotificationControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get notification_destroy_url
    assert_response :success
  end

end
