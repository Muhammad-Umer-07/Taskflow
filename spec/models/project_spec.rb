require "rails_helper"

RSpec.describe Project, type: :model do
  subject(:project) { described_class.new(title: "Launch", creator: users(:manager)) }

  it "defines the expected associations" do
    expect(described_class.reflect_on_association(:creator).class_name).to eq("User")
    expect(described_class.reflect_on_association(:project_memberships).options[:dependent]).to eq(:destroy)
    expect(described_class.reflect_on_association(:users).options[:through]).to eq(:project_memberships)
    expect(described_class.reflect_on_association(:tasks).options[:dependent]).to eq(:destroy)
  end

  it "requires a title with supported lengths" do
    project.title = nil
    expect(project).not_to be_valid

    project.title = "a" * 101
    expect(project).not_to be_valid

    project.title = "Launch"
    project.description = "a" * 1001
    expect(project).not_to be_valid
  end

  it "requires titles to be unique per creator" do
    described_class.create!(title: "Unique project", creator: users(:manager))

    expect(described_class.new(title: "Unique project", creator: users(:manager))).not_to be_valid
    expect(described_class.new(title: "Unique project", creator: users(:admin))).to be_valid
  end

  it "adds its creator as a manager" do
    project.save!

    expect(project.project_memberships.find_by(user: project.creator)).to be_manager
  end


  it "destroys associated tasks and memberships" do
    project.save!
    task = project.tasks.create!(title: "Dependent task")
    membership = project.project_memberships.first

    project.destroy!

    expect(described_class).not_to exist(project.id)
    expect(Task).not_to exist(task.id)
    expect(ProjectMembership).not_to exist(membership.id)
  end
end
