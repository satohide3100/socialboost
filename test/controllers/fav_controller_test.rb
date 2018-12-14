require 'test_helper'

class FavControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get fav_list_url
    assert_response :success
  end

end
