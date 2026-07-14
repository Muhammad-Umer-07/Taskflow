require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
<<<<<<< Updated upstream
  # test "the truth" do
  #   assert true
  # end
=======
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
>>>>>>> Stashed changes
end
