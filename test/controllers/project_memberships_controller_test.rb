require "test_helper"

class ProjectMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "project creator can add a member" do
    project = projects(:website_redesign)
    user = User.create!(email: "collaborator@example.com", password: "Collaborator1!")
    sign_in users(:manager)

    assert_difference("project.project_memberships.count") do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "member" }
    end

    assert_equal "member", project.project_memberships.order(:id).last.role
    assert_redirected_to project_path(project)
  end

  test "project-level manager can add a member" do
    project = projects(:website_redesign)
    user = User.create!(email: "teammate@example.com", password: "Teammate1!")
    sign_in users(:project_manager)

    assert_difference("project.project_memberships.count") do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "member" }
    end

    assert_equal "member", project.project_memberships.order(:id).last.role
    assert_redirected_to project_path(project)
  end

  test "admin can assign a project manager" do
    project = projects(:website_redesign)
    user = User.create!(email: "new-manager@example.com", password: "Manager123!", role: :member)
    sign_in users(:admin)

    assert_difference("project.project_memberships.count") do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end

    assert_equal "manager", project.project_memberships.order(:id).last.role
    assert_redirected_to project_path(project)
  end

  test "non-admin manager cannot assign the manager role" do
    project = projects(:website_redesign)
    user = User.create!(email: "promoted@example.com", password: "Promoted1!", role: :member)
    sign_in users(:manager)

    assert_difference("project.project_memberships.count") do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end

    assert_equal "member", project.project_memberships.order(:id).last.role
    assert_redirected_to project_path(project)
  end

  test "rejects an invalid member selection" do
    project = projects(:website_redesign)
    sign_in users(:manager)

    assert_no_difference("project.project_memberships.count") do
      post project_project_memberships_path(project), params: { user_id: "", role: "member" }
    end

    assert_redirected_to project_path(project)
  end
end
