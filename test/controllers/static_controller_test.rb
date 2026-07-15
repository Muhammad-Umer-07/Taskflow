require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "renders the home page" do
    get root_path

    assert_response :success
  end

  test "root route uses the static home action" do
    assert_routing "/", controller: "static", action: "home"
  end
end
