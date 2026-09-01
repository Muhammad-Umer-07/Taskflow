require "rails_helper"

RSpec.describe "Home", type: :request do
  it "renders the public landing page without authentication" do
    get root_path

    expect(response).to have_http_status(:ok)
  end

  it "routes the root URL to home#index" do
    expect(Rails.application.routes.recognize_path("/")).to include(controller: "home", action: "index")
  end
end
