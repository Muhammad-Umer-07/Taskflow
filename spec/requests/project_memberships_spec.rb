require "rails_helper"

RSpec.describe "Project memberships", type: :request do
  let(:creator) do
    User.create!(
      email: "creator@example.com", password: "Password1!", password_confirmation: "Password1!", role: :manager
    )
  end
  let(:project) { Project.create!(title: "Website Redesign", creator: creator) }

  it "allows admins to assign the manager role" do
    admin = User.create!(
      email: "admin-spec@example.com", password: "Password1!", password_confirmation: "Password1!", role: :admin
    )
    user = User.create!(
      email: "candidate@example.com", password: "Password1!", password_confirmation: "Password1!", role: :member
    )

    sign_in admin

    expect do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end.to change(project.project_memberships, :count).by(1)

    expect(project.project_memberships.order(:id).last.role).to eq("manager")
  end

  it "downgrades non-admin manager assignment attempts to member" do
    user = User.create!(
      email: "candidate-two@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      role: :member
    )

    sign_in creator

    expect do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end.to change(project.project_memberships, :count).by(1)

    expect(project.project_memberships.order(:id).last.role).to eq("member")
  end

  it "rejects an invalid user selection" do
    project
    sign_in creator

    expect do
      post project_project_memberships_path(project), params: { user_id: "missing", role: "member" }
    end.not_to change(ProjectMembership, :count)
    expect(response).to redirect_to(project)
  end

  it "reports duplicate memberships" do
    project
    sign_in creator

    expect do
      post project_project_memberships_path(project), params: { user_id: creator.id, role: "member" }
    end.not_to change(ProjectMembership, :count)
    expect(response).to redirect_to(project)
    expect(flash[:alert]).to be_present
  end

  it "removes a project member" do
    member = User.create!(email: "membership-remove@example.com", password: "Password1!")
    membership = project.project_memberships.create!(user: member)
    sign_in creator

    expect do
      delete project_project_membership_path(project, membership)
    end.to change(ProjectMembership, :count).by(-1)
    expect(response).to redirect_to(project)
  end

  it "keeps the project creator membership" do
    project
    membership = project.project_memberships.find_by!(user: creator)
    sign_in creator

    expect do
      delete project_project_membership_path(project, membership)
    end.not_to change(ProjectMembership, :count)
    expect(flash[:alert]).to be_present
  end

  it "denies membership management to ordinary members" do
    member = User.create!(email: "ordinary-member@example.com", password: "Password1!")
    project.project_memberships.create!(user: member)
    candidate = User.create!(email: "membership-candidate@example.com", password: "Password1!")
    sign_in member

    expect do
      post project_project_memberships_path(project), params: { user_id: candidate.id }
    end.not_to change(ProjectMembership, :count)
    expect(response).to redirect_to(root_path)
  end
end
