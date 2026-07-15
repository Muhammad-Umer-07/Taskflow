require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get projects_path

    assert_redirected_to new_user_session_path
  end

  test "manager can create a project" do
    sign_in users(:manager)

    assert_difference("Project.count") do
      post projects_path, params: { project: { title: "New Project", description: "A new initiative" } }
    end

    assert_redirected_to project_path(Project.last)
  end

  test "member cannot create a project" do
    sign_in users(:member)

    assert_no_difference("Project.count") do
      post projects_path, params: { project: { title: "Blocked", description: "Not allowed" } }
    end

    assert_redirected_to root_path
  end

  test "project member picker excludes admins" do
    eligible_member = User.create!(email: "eligible_member@example.com", password: "Eligible1!", role: :member)
    sign_in users(:admin)

    get project_path(projects(:website_redesign))

    assert_response :success
    assert_select "select[name='user_id'] option", text: eligible_member.email
    assert_select "select[name='user_id'] option", text: "admin@example.com", count: 0
    assert_select "select[name='user_id'] option", text: "manager@example.com", count: 0
  end

  test "workspace displays an admin membership as Admin" do
    sign_in users(:admin)

    get project_path(projects(:mobile_app))

    assert_response :success
    assert_select "tr", text: /admin@example\.com.*Admin/
  end

  test "member picker does not list the signed-in manager" do
    manager = users(:manager)
    sign_in manager

    get project_path(projects(:website_redesign))

    assert_response :success
    assert_select "select[name='user_id'] option", text: manager.email, count: 0
  end
end
