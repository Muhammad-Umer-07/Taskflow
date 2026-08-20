require "rails_helper"

RSpec.describe Task, type: :model do
  subject(:task) { described_class.new(title: "Plan launch", project: projects(:website_redesign)) }

  it "belongs to a project and optionally belongs to an assignee" do
    project_association = described_class.reflect_on_association(:project)
    assignee_association = described_class.reflect_on_association(:assignee)

    expect(project_association.macro).to eq(:belongs_to)
    expect(assignee_association.class_name).to eq("User")
    expect(assignee_association.options[:optional]).to be(true)
    expect(described_class.statuses).to eq("todo" => 0, "in_progress" => 1, "done" => 2)
  end

  it "validates its title and description lengths" do
    task.title = nil
    expect(task).not_to be_valid

    task.title = "a" * 101
    expect(task).not_to be_valid

    task.title = "Plan launch"
    task.description = "a" * 501
    expect(task).not_to be_valid
  end

  it "defaults to todo and exposes assignment scopes" do
    task.assignee = users(:manager)
    task.save!
    expect(task).to be_todo
    expect(described_class.assigned_to(users(:manager))).to include(task)
    expect(described_class.completed).not_to include(task)

    task.update!(status: :done)
    expect(described_class.completed).to include(task)
  end

  it "requires an assignee to belong to the project" do
    task.assignee = users(:admin)

    expect(task).not_to be_valid
    expect(task.errors[:assignee]).to include("must be a member of the project")
  end


  it "accepts an unassigned task or a project member as assignee" do
    expect(task).to be_valid

    task.assignee = users(:member)
    expect(task).to be_valid
  end
end
