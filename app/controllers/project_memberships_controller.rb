# frozen_string_literal: true

class ProjectMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def create
<<<<<<< Updated upstream
    authorize @project, :update?

    membership = @project.project_memberships.new(membership_params)

    if membership.save
      redirect_to @project, notice: "Member invited successfully."
    else
      redirect_to @project, alert: membership.errors.full_messages.to_sentence
=======
    authorize @project, :manage_members?, policy_class: ProjectPolicy

    user = User.find_by(id: params[:user_id])

    unless user
      redirect_to @project, alert: "Please select a valid user to add."
      return
    end

    role = permitted_role(params[:role])
    @membership = @project.project_memberships.build(user: user, role: role)

    if @membership.save
      redirect_to @project, notice: "#{user.email} added to project."
    else
      redirect_to @project, alert: "User is already a member or failed to add."
>>>>>>> Stashed changes
    end
  end

  def destroy
<<<<<<< Updated upstream
    authorize @project, :update?
=======
    @membership = @project.project_memberships.find(params[:id])
    authorize @project, :manage_members?, policy_class: ProjectPolicy
>>>>>>> Stashed changes

    membership = @project.project_memberships.find(params[:id])
    membership.destroy

    redirect_to @project,
                notice: "Member removed successfully."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

<<<<<<< Updated upstream
  def membership_params
    params.require(:project_membership)
          .permit(:user_id, :role)
  end
end
=======
  def permitted_role(requested_role)
    return :manager if requested_role == "manager" && current_user.admin?

    :member
  end
end
>>>>>>> Stashed changes
