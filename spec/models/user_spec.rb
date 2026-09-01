require "rails_helper"

RSpec.describe User, type: :model do
  it "defines role and project associations" do
    expect(described_class.roles).to eq("admin" => 0, "manager" => 1, "member" => 2)
    expect(described_class.reflect_on_association(:assigned_tasks).options[:dependent]).to eq(:nullify)
    expect(described_class.reflect_on_association(:created_projects).options[:dependent]).to eq(:destroy)
    expect(described_class.reflect_on_association(:project_memberships).options[:dependent]).to eq(:destroy)
    expect(described_class.reflect_on_association(:projects).options[:through]).to eq(:project_memberships)
  end

  it "defaults role to member" do
    user = described_class.create!(
      email: "rspec-default-role@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    )

    expect(user.role).to eq("member")
  end

  it "rejects invalid email addresses" do
    user = described_class.new(email: "invalid", password: "Password1!", password_confirmation: "Password1!")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("must be a valid email address")
  end

  it "requires uppercase, lowercase, number, and symbol in passwords" do
    user = described_class.new(email: "weak@example.com", password: "password1!", password_confirmation: "password1!")

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(User::PASSWORD_COMPLEXITY_MESSAGE)
  end

  it "accepts valid public email addresses and complex passwords" do
    user = described_class.new(
      email: "user.name+tag@example.co.uk", password: "Password1!", password_confirmation: "Password1!"
    )

    expect(user).to be_valid
  end

  it "rejects malformed public email addresses" do
    [ "user@example", "user@localhost", "user@example..com" ].each do |email|
      user = described_class.new(email: email, password: "Password1!", password_confirmation: "Password1!")
      expect(user).not_to be_valid
    end
  end


  it "rejects emails longer than 255 characters" do
    user = described_class.new(
      email: "#{"a" * 244}@example.com", password: "Password1!", password_confirmation: "Password1!"
    )

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is too long (maximum is 255 characters)")
  end


  it "nullifies task assignments when the assignee is destroyed" do
    assignee = described_class.create!(email: "temporary-assignee@example.com", password: "Password1!")
    project = Project.create!(title: "Assignment project", creator: users(:manager))
    project.project_memberships.create!(user: assignee)
    task = project.tasks.create!(title: "Assigned task", assignee: assignee)

    assignee.destroy!

    expect(task.reload.assignee).to be_nil
  end
end
