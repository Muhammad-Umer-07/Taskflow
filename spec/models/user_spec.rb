require "rails_helper"

RSpec.describe User, type: :model do
  it "defaults role to member" do
    user = described_class.create!(email: "rspec-default-role@example.com", password: "Password1!", password_confirmation: "Password1!")

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
    expect(user.errors[:password]).to include("must include at least one uppercase letter, one lowercase letter, one number, and one symbol")
  end
end
