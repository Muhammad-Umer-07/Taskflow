require "rails_helper"

RSpec.describe "Project memberships", type: :request do
  let(:creator) do
    User.create!(email: "creator@example.com", password: "Password1!", password_confirmation: "Password1!", role: :manager)
  end
  let(:project) { Project.create!(title: "Website Redesign", creator: creator) }

  it "allows admins to assign the manager role" do
    admin = User.create!(email: "admin-spec@example.com", password: "Password1!", password_confirmation: "Password1!", role: :admin)
    user = User.create!(email: "candidate@example.com", password: "Password1!", password_confirmation: "Password1!", role: :member)

    sign_in admin

    expect do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end.to change(project.project_memberships, :count).by(1)

    expect(project.project_memberships.order(:id).last.role).to eq("manager")
  end

  it "downgrades non-admin manager assignment attempts to member" do
    user = User.create!(email: "candidate-two@example.com", password: "Password1!", password_confirmation: "Password1!", role: :member)

    sign_in creator

    expect do
      post project_project_memberships_path(project), params: { user_id: user.id, role: "manager" }
    end.to change(project.project_memberships, :count).by(1)

    expect(project.project_memberships.order(:id).last.role).to eq("member")
  end
end
