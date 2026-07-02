require "test_helper"

class TaskPolicyTest < ActiveSupport::TestCase
  test "allows an assignee to update a task" do
    policy = TaskPolicy.new(users(:member), tasks(:design_mockups))

    assert_predicate policy, :update?
  end

  test "does not allow a non-assignee member to create tasks" do
    task = Task.new(project: projects(:website_redesign))
    policy = TaskPolicy.new(users(:member), task)

    assert_not_predicate policy, :create?
  end
end
