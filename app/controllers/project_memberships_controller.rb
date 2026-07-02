class ProjectMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def create
    authorize @project, :update?

    membership = @project.project_memberships.new(membership_params)

    if membership.save
      redirect_to @project, notice: "Member invited successfully."
    else
      redirect_to @project, alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @project, :update?

    membership = @project.project_memberships.find(params[:id])
    membership.destroy

    redirect_to @project,
                notice: "Member removed successfully."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def membership_params
    params.require(:project_membership)
          .permit(:user_id, :role)
  end
end