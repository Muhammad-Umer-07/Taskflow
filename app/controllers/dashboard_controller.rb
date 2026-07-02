class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @projects =
      if current_user.admin?
        Project.includes(:users, :tasks)
      else
        current_user.projects.includes(:users, :tasks)
      end

    @assigned_tasks =
      Task.assigned_to(current_user)
          .includes(:project, :assignee)

    if params[:status].present? && Task.statuses.keys.include?(params[:status])
      @assigned_tasks = @assigned_tasks.where(status: params[:status])
    end
  end
end