require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "renders the home page" do
    get root_path

    assert_response :success
  end
end
