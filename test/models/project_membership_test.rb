require "test_helper"

class ProjectMembershipTest < ActiveSupport::TestCase
  test "defaults to the member role" do
    membership = ProjectMembership.create!(user: users(:admin), project: projects(:website_redesign))

    assert_predicate membership, :member?
  end

  test "does not destroy the project creator's membership" do
    project = projects(:website_redesign)
    membership = project.project_memberships.find_by!(user: project.creator)

    assert_not membership.destroy
    assert_includes membership.errors.full_messages, "The project creator cannot be removed from the project"
  end

  test "unassigns the removed member's project tasks" do
    project = projects(:website_redesign)
    member = users(:member)
    membership = project.project_memberships.find_by!(user: member)
    task = tasks(:design_mockups)

    assert membership.destroy
    assert_nil task.reload.assignee
  end
end
