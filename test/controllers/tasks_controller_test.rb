require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "project member can view tasks on the project page" do
    sign_in users(:member)

    get project_path(projects(:website_redesign))

    assert_response :success
  end

  test "project manager can create a task" do
    project = projects(:website_redesign)
    sign_in users(:manager)

    assert_difference("project.tasks.count") do
      post project_tasks_path(project), params: { task: { title: "Review copy", description: "Review landing page copy", status: "todo" } }
    end

    assert_redirected_to project_path(project)
  end

  test "invalid project id on new task redirects with an error message" do
    sign_in users(:manager)

    get "/projects/project_id/tasks/new"

    assert_redirected_to projects_path
    follow_redirect!
    assert_match "The requested project could not be found.", response.body
  end

  test "project member can view the task index" do
    project = projects(:website_redesign)
    sign_in users(:member)

    get project_tasks_path(project)

    assert_response :success
  end

  test "uninvited member cannot view another project's tasks" do
    sign_in users(:member)

    get project_tasks_path(projects(:mobile_app))

    assert_redirected_to root_path
  end

  test "project member can view a task" do
    task = tasks(:design_mockups)
    sign_in users(:member)

    get project_task_path(task.project, task)

    assert_response :success
    assert_select "h1", task.title
  end

  test "assignee can update status but cannot forge other task attributes" do
    task = tasks(:design_mockups)
    original_title = task.title
    sign_in users(:member)

    patch project_task_path(task.project, task), params: {
      task: { title: "Forged title", description: "Forged description", assignee_id: users(:manager).id, status: "done" }
    }

    assert_redirected_to project_tasks_path(task.project)
    task.reload
    assert_equal original_title, task.title
    assert_predicate task, :done?
    assert_equal users(:member), task.assignee
  end

  test "non-assignee member cannot update a task" do
    project = projects(:website_redesign)
    outsider = User.create!(email: "other-member@example.com", password: "Password1!", role: :member)
    project.project_memberships.create!(user: outsider, role: :member)
    task = tasks(:design_mockups)
    sign_in outsider

    patch project_task_path(project, task), params: { task: { status: "done" } }

    assert_redirected_to root_path
    assert_not_predicate task.reload, :done?
  end
end
