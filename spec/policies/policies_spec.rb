require "rails_helper"

RSpec.describe "Authorization policies" do
  describe ProjectPolicy do
    let(:project) { projects(:website_redesign) }

    it "scopes projects by role" do
      expect(described_class::Scope.new(users(:admin), Project.all).resolve).to include(projects(:mobile_app), project)
      expect(described_class::Scope.new(users(:manager), Project.all).resolve).to include(project)
      expect(described_class::Scope.new(users(:member), Project.all).resolve).to contain_exactly(project)
    end

    it "authorizes project actions by role and membership" do
      expect(described_class.new(users(:admin), project)).to be_create
      expect(described_class.new(users(:manager), project)).to be_update
      expect(described_class.new(users(:member), project)).to be_show
      expect(described_class.new(users(:member), project)).not_to be_update
      expect(described_class.new(users(:member), Project.new)).not_to be_create
    end
  end

  describe ProjectMembershipPolicy do
    let(:project) { projects(:website_redesign) }
    let(:membership) { project_memberships(:website_member) }

    it "allows admins, creators, and project managers to manage memberships" do
      expect(described_class.new(users(:admin), membership)).to be_destroy
      expect(described_class.new(users(:manager), membership)).to be_destroy
      expect(described_class.new(users(:project_manager), membership)).to be_destroy
      expect(described_class.new(users(:manager), ProjectMembership.new(project: project))).to be_create
    end

    it "denies ordinary members and protects the project creator membership" do
      creator_membership = project_memberships(:website_manager)

      expect(described_class.new(users(:member), membership)).not_to be_destroy
      expect(described_class.new(users(:member), ProjectMembership.new(project: project))).not_to be_create
      expect(described_class.new(users(:admin), creator_membership)).not_to be_destroy
    end
  end

  describe TaskPolicy do
    let(:task) { tasks(:design_mockups) }

    it "scopes tasks to projects visible to the user" do
      expect(described_class::Scope.new(users(:admin), Task.all).resolve).to include(task)
      expect(described_class::Scope.new(users(:member), Task.all).resolve).to include(task)
    end

    it "allows managers full attributes and assignees status only" do
      expect(described_class.new(users(:manager), task).permitted_attributes).to include(:title, :assignee_id)
      expect(described_class.new(users(:member), task).permitted_attributes).to eq([ :status ])
      expect(described_class.new(users(:admin), task)).to be_destroy
    end

    it "denies task changes to unrelated members" do
      outsider = User.create!(email: "policy-outsider@example.com", password: "Password1!")
      policy = described_class.new(outsider, task)

      expect(policy).not_to be_show
      expect(policy).not_to be_create
      expect(policy).not_to be_update
      expect(policy).not_to be_destroy
      expect(policy.permitted_attributes).to be_empty
    end
  end

  describe UserPolicy do
    it "allows only admins to manage users and scope the user list" do
      admin_policy = described_class.new(users(:admin), users(:member))
      manager_policy = described_class.new(users(:manager), users(:member))

      expect(admin_policy).to be_index
      expect(admin_policy).to be_update
      expect(admin_policy).to be_destroy
      expect(manager_policy).not_to be_index
      expect(described_class::Scope.new(users(:admin), User.all).resolve).not_to be_empty
      expect(described_class::Scope.new(users(:manager), User.all).resolve).to be_empty
    end
  end
end
