class DashboardController < ApplicationController
  def index
    @projects = projects_scope.includes(:users, :tasks)
    @assigned_tasks = filtered_assigned_tasks.includes(:project)
    @completed_assigned_tasks_count = @assigned_tasks.done.count
  end

  private

  def projects_scope
    current_user.admin? ? Project.all : current_user.projects
  end

  def filtered_assigned_tasks
    tasks = Task.assigned_to(current_user)
    return tasks unless valid_status_filter?

    tasks.where(status: params[:status])
  end

  def valid_status_filter?
    params[:status].present? && Task.statuses.key?(params[:status])
  end
end
