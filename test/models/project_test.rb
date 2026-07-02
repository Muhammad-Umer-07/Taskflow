require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires a title" do
    project = Project.new(creator: users(:manager))

    assert_not project.valid?
    assert_includes project.errors[:title], "can't be blank"
  end

  test "limits title length to 100 characters" do
    project = Project.new(title: "a" * 101, creator: users(:manager))

    assert_not project.valid?
    assert_includes project.errors[:title], "is too long (maximum is 100 characters)"
  end

  test "limits description length to 1000 characters" do
    project = Project.new(title: "Launch", description: "a" * 1001, creator: users(:manager))

    assert_not project.valid?
    assert_includes project.errors[:description], "is too long (maximum is 1000 characters)"
  end

  test "creates a manager membership for its creator" do
    project = Project.create!(title: "Launch", creator: users(:manager))

    membership = project.project_memberships.find_by(user: users(:manager))
    assert_equal "manager", membership.role
  end
end
