require "rails_helper"

RSpec.describe ProjectMembership, type: :model do
  it "belongs to a user and project and defines both roles" do
    expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
    expect(described_class.reflect_on_association(:project).macro).to eq(:belongs_to)
    expect(described_class.roles).to eq("manager" => 0, "member" => 1)
  end

  it "defaults to member and prevents duplicate memberships" do
    membership = described_class.new(user: users(:admin), project: projects(:website_redesign))
    expect(membership).to be_member
    expect(membership).to be_valid

    duplicate = described_class.new(user: users(:member), project: projects(:website_redesign))
    expect(duplicate).not_to be_valid
  end

  it "prevents removal of the creator membership" do
    membership = projects(:website_redesign).project_memberships.find_by!(user: users(:manager))

    expect(membership.destroy).to be(false)
    expect(membership.errors.full_messages).to include("The project creator cannot be removed from the project")
  end

  it "unassigns the removed member's tasks" do
    membership = project_memberships(:website_member)

    expect(membership.destroy).to be_truthy
    expect(tasks(:design_mockups).reload.assignee).to be_nil
  end


  it "allows removal of creator membership while its project is being destroyed" do
    project = Project.create!(title: "Cascading membership", creator: users(:manager))
    membership_id = project.project_memberships.find_by!(user: project.creator).id

    expect(project.destroy).to be_truthy
    expect(described_class).not_to exist(membership_id)
  end
end
