require "test_helper"

class ProjectMembershipTest < ActiveSupport::TestCase
  test "defaults to the member role" do
    membership = ProjectMembership.create!(user: users(:admin), project: projects(:website_redesign))

    assert_predicate membership, :member?
  end
end
