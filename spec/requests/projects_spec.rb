require "rails_helper"

RSpec.describe "Projects", type: :request do
  it "requires authentication" do
    get projects_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "lists scoped projects" do
    sign_in users(:member)
    get projects_path
    expect(response).to have_http_status(:ok)
  end

  it "renders new for managers but denies members" do
    sign_in users(:manager)
    get new_project_path
    expect(response).to have_http_status(:ok)

    sign_out users(:manager)
    sign_in users(:member)
    get new_project_path
    expect(response).to redirect_to(root_path)
  end

  it "creates valid projects and renders errors for invalid projects" do
    sign_in users(:manager)

    expect do
      post projects_path, params: { project: { title: "RSpec project", description: "Covered" } }
    end.to change(Project, :count).by(1)
    expect(response).to redirect_to(Project.last)

    expect do
      post projects_path, params: { project: { title: "" } }
    end.not_to change(Project, :count)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "shows and edits an authorized project" do
    sign_in users(:manager)
    project = projects(:website_redesign)

    get project_path(project)
    expect(response).to have_http_status(:ok)
    get edit_project_path(project)
    expect(response).to have_http_status(:ok)
  end

  it "allows admins, managers, and members to appear in the project member picker" do
    project = projects(:website_redesign)
    sign_in users(:manager)

    get project_path(project)

    document = Nokogiri::HTML(response.body)
    available_user_ids = document.css("select[name='user_id'] option").filter_map { |option| option["value"].presence }
    expect(available_user_ids).to include(users(:admin).id.to_s, users(:two).id.to_s, users(:three).id.to_s)
    expect(available_user_ids).not_to include(users(:member).id.to_s, users(:manager).id.to_s)
  end

  it "updates valid projects and renders errors for invalid updates" do
    sign_in users(:manager)
    project = projects(:website_redesign)

    patch project_path(project), params: { project: { title: "Updated title" } }
    expect(response).to redirect_to(project)
    expect(project.reload.title).to eq("Updated title")

    patch project_path(project), params: { project: { title: "" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "deletes an authorized project and denies an unauthorized update" do
    project = Project.create!(title: "Disposable", creator: users(:manager))
    sign_in users(:manager)
    expect { delete project_path(project) }.to change(Project, :count).by(-1)
    expect(response).to redirect_to(projects_path)

    sign_out users(:manager)
    sign_in users(:member)
    patch project_path(projects(:website_redesign)), params: { project: { title: "Forged" } }
    expect(response).to redirect_to(root_path)
  end

  it "keeps the project and reports errors when deletion fails" do
    project = projects(:website_redesign)
    sign_in users(:manager)
    allow_any_instance_of(Project).to receive(:destroy) do |record|
      record.errors.add(:base, "Project could not be deleted")
      false
    end

    expect { delete project_path(project) }.not_to change(Project, :count)

    expect(response).to redirect_to(project)
    expect(flash[:alert]).to eq("Project could not be deleted")
  end

  it "handles missing projects" do
    sign_in users(:admin)
    get project_path(id: "missing")
    expect(response).to redirect_to(root_path)
  end
end
