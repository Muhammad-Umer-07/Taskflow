require "rails_helper"

RSpec.describe "Tasks", type: :request do
  it "redirects invalid nested new-task paths with a clear error" do
    manager = User.create!(email: "task-manager@example.com", password: "Password1!", password_confirmation: "Password1!", role: :manager)

    sign_in manager
    get "/projects/project_id/tasks/new"

    expect(response).to redirect_to(projects_path)
    follow_redirect!
    expect(response.body).to include("The requested project could not be found.")
  end
end
