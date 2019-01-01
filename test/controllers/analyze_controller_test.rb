require 'test_helper'

class AnalyzeControllerTest < ActionDispatch::IntegrationTest
  test "should get twitter" do
    get analyze_twitter_url
    assert_response :success
  end

end
