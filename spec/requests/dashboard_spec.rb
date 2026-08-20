require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  it "renders projects and assigned tasks available to the signed-in user" do
    sign_in users(:member)

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(project_tasks_path(tasks(:design_mockups).project, from: "dashboard"))
  end

  it "accepts valid status filters and ignores invalid filters" do
    sign_in users(:member)

    get dashboard_path, params: { status: "in_progress" }
    expect(response).to have_http_status(:ok)

    get dashboard_path, params: { status: "invalid" }
    expect(response).to have_http_status(:ok)
  end

  it "keeps the completed total independent of the active status filter" do
    member = users(:member)
    project = projects(:website_redesign)
    project.tasks.create!(title: "Completed dashboard task", assignee: member, status: :done)
    sign_in member

    get dashboard_path, params: { status: "todo" }

    document = Nokogiri::HTML(response.body)
    completed_count = document.at_xpath("//span[normalize-space()='Done Tasks']/following-sibling::h3")
    expect(completed_count.text.strip).to eq("1")
  end
end
