require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get account_list_url
    assert_response :success
  end

end
