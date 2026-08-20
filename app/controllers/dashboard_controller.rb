class DashboardController < ApplicationController
  def index
    assigned_tasks = policy_scope(Task).assigned_to(current_user)

    @projects = projects_scope.includes(:users, :tasks)
    @assigned_tasks = filtered_assigned_tasks(assigned_tasks).includes(:project)
    @completed_assigned_tasks_count = assigned_tasks.done.count
  end

  private

  def projects_scope
    policy_scope(Project)
  end

  def filtered_assigned_tasks(tasks)
    return tasks unless valid_status_filter?

    tasks.where(status: params[:status])
  end

  def valid_status_filter?
    params[:status].present? && Task.statuses.key?(params[:status])
  end
end
