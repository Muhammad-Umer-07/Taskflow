require "rails_helper"

RSpec.describe "Tasks", type: :request do
  it "redirects invalid nested new-task paths with a clear error" do
    manager = User.create!(
      email: "task-manager@example.com", password: "Password1!", password_confirmation: "Password1!", role: :manager
    )

    sign_in manager
    get "/projects/project_id/tasks/new"

    expect(response).to redirect_to(projects_path)
    follow_redirect!
    expect(response.body).to include("The requested project could not be found.")
  end

  it "lists and shows tasks for project members" do
    sign_in users(:member)
    task = tasks(:design_mockups)

    get project_tasks_path(task.project)
    expect(response).to have_http_status(:ok)
    get project_task_path(task.project, task)
    expect(response).to have_http_status(:ok)
  end

  it "links back to the dashboard when opened from the dashboard" do
    project = projects(:website_redesign)
    sign_in users(:member)

    get project_tasks_path(project, from: "dashboard")

    expect(response.body).to include("Back to dashboard")
    expect(response.body).to include("href=\"#{dashboard_path}\"")
  end

  it "links back to the project by default" do
    project = projects(:website_redesign)
    sign_in users(:member)

    get project_tasks_path(project)

    expect(response.body).to include("Back to project")
    expect(response.body).to include("href=\"#{project_path(project)}\"")
  end

  it "denies a project task list to unrelated members" do
    sign_in users(:member)
    get project_tasks_path(projects(:mobile_app))
    expect(response).to redirect_to(root_path)
  end

  it "renders the new task form for a manager" do
    sign_in users(:manager)
    get new_project_task_path(projects(:website_redesign))
    expect(response).to have_http_status(:ok)
  end

  it "creates valid tasks and renders errors for invalid tasks" do
    project = projects(:website_redesign)
    sign_in users(:manager)

    expect do
      post project_tasks_path(project), params: { task: { title: "RSpec task", status: "todo" } }
    end.to change(Task, :count).by(1)
    expect(response).to redirect_to(project)

    expect do
      post project_tasks_path(project), params: { task: { title: "" } }
    end.not_to change(Task, :count)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "renders edit and updates a task for a manager" do
    task = tasks(:design_mockups)
    sign_in users(:manager)

    get edit_project_task_path(task.project, task)
    expect(response).to have_http_status(:ok)

    patch project_task_path(task.project, task), params: { task: { title: "Revised task" } }
    expect(response).to redirect_to(project_tasks_path(task.project))
    expect(task.reload.title).to eq("Revised task")
  end

  it "limits assignees to status updates" do
    task = tasks(:design_mockups)
    sign_in users(:member)

    patch project_task_path(task.project, task), params: { task: { title: "Forged", status: "done" } }
    expect(response).to redirect_to(project_tasks_path(task.project))
    expect(task.reload.title).not_to eq("Forged")
    expect(task).to be_done
  end

  it "renders errors for an invalid update" do
    task = tasks(:design_mockups)
    sign_in users(:manager)

    patch project_task_path(task.project, task), params: { task: { title: "" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "deletes tasks for managers and denies unrelated users" do
    task = Task.create!(title: "Disposable task", project: projects(:website_redesign))
    sign_in users(:manager)
    expect { delete project_task_path(task.project, task) }.to change(Task, :count).by(-1)

    outsider = User.create!(email: "task-outsider@example.com", password: "Password1!")
    sign_out users(:manager)
    sign_in outsider
    get project_task_path(tasks(:design_mockups).project, tasks(:design_mockups))
    expect(response).to redirect_to(root_path)
  end

  it "handles a missing task within a valid project" do
    sign_in users(:manager)
    get project_task_path(projects(:website_redesign), id: "missing")
    expect(response).to redirect_to(root_path)
  end
end
