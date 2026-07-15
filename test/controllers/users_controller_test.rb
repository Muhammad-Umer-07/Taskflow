require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "admin can list users" do
    sign_in users(:admin)

    get users_path

    assert_response :success
    assert_select "h1", "Manage Users"
  end

  test "admin can update a user role" do
    user = users(:member)
    sign_in users(:admin)

    patch user_path(user), params: { user: { role: "manager" } }

    assert_redirected_to users_path
    assert_predicate user.reload, :manager?
  end

  test "non-admin cannot list users" do
    sign_in users(:manager)

    get users_path

    assert_redirected_to root_path
  end

  test "non-admin cannot update user roles" do
    user = users(:member)
    sign_in users(:manager)

    patch user_path(user), params: { user: { role: "admin" } }

    assert_redirected_to root_path
    assert_predicate user.reload, :member?
  end

  test "admin can delete another user" do
    user = User.create!(email: "deletable@example.com", password: "Password1!", role: :member)
    sign_in users(:admin)

    assert_difference("User.count", -1) do
      delete user_path(user)
    end

    assert_redirected_to users_path
  end

  test "admin cannot delete their own active account" do
    admin = users(:admin)
    sign_in admin

    assert_no_difference("User.count") do
      delete user_path(admin)
    end

    assert_redirected_to users_path
    assert User.exists?(admin.id)
  end

  test "non-admin cannot delete users" do
    user = users(:member)
    sign_in users(:manager)

    assert_no_difference("User.count") do
      delete user_path(user)
    end

    assert_redirected_to root_path
  end
end
