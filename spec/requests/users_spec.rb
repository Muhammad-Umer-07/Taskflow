require "rails_helper"

RSpec.describe "Users", type: :request do
  it "allows admins to list users" do
    sign_in users(:admin)
    get users_path
    expect(response).to have_http_status(:ok)
  end

  it "denies the user list to non-admins" do
    sign_in users(:manager)
    get users_path
    expect(response).to redirect_to(root_path)
  end

  it "allows admins to update a valid role" do
    sign_in users(:admin)
    patch user_path(users(:member)), params: { user: { role: "manager" } }
    expect(response).to redirect_to(users_path)
    expect(users(:member).reload).to be_manager
  end

  it "prevents an admin from changing their own role" do
    admin = users(:admin)
    sign_in admin

    patch user_path(admin), params: { user: { role: "member" } }

    expect(response).to redirect_to(users_path)
    expect(flash[:alert]).to eq("You cannot change your own role.")
    expect(admin.reload).to be_admin
  end

  it "does not render role or delete controls for the current admin" do
    admin = users(:admin)
    sign_in admin

    get users_path

    document = Nokogiri::HTML(response.body)
    expect(document.at_css("form[action='#{user_path(admin)}']")).to be_nil
    expect(response.body).to include("Current account")
  end

  it "rejects invalid roles" do
    sign_in users(:admin)
    patch user_path(users(:member)), params: { user: { role: "invalid" } }
    expect(response).to redirect_to(users_path)
    expect(flash[:alert]).to eq("Please select a valid role.")
  end

  it "allows an admin to delete another user but not themselves" do
    admin = users(:admin)
    victim = User.create!(email: "delete-spec@example.com", password: "Password1!")
    sign_in admin

    expect { delete user_path(victim) }.to change(User, :count).by(-1)
    expect(response).to redirect_to(users_path)

    expect { delete user_path(admin) }.not_to change(User, :count)
    expect(response).to redirect_to(users_path)
  end
end
