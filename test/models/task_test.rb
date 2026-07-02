require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires a title" do
    task = Task.new(project: projects(:website_redesign))

    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "limits title length to 100 characters" do
    task = Task.new(title: "a" * 101, project: projects(:website_redesign))

    assert_not task.valid?
    assert_includes task.errors[:title], "is too long (maximum is 100 characters)"
  end

  test "limits description length to 500 characters" do
    task = Task.new(title: "Plan launch", description: "a" * 501, project: projects(:website_redesign))

    assert_not task.valid?
    assert_includes task.errors[:description], "is too long (maximum is 500 characters)"
  end

  test "defaults to todo status" do
    task = Task.create!(title: "Plan launch", project: projects(:website_redesign))

    assert_predicate task, :todo?
  end

  test "completed scope returns only done tasks" do
    tasks(:design_mockups).update!(status: :done)

    assert_equal [ tasks(:design_mockups) ], Task.completed.to_a
  end
end
