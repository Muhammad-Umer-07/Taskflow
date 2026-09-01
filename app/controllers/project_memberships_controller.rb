# frozen_string_literal: true

class ProjectMembershipsController < ApplicationController
  before_action :set_project

  def create
    @membership = @project.project_memberships.build
    authorize @membership

    user = User.find_by(id: params[:user_id])

    unless user
      redirect_to @project, alert: "Please select a valid user to add."
      return
    end

    role = permitted_role(params[:role])
    @membership.assign_attributes(user: user, role: role)

    if @membership.save
      redirect_to @project, notice: "#{user.email} added to project."
    else
      redirect_to @project, alert: @membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    @membership = @project.project_memberships.find(params[:id])
    authorize @membership

    if @membership.destroy
      redirect_to @project, notice: "Member removed successfully."
    else
      redirect_to @project, alert: @membership.errors.full_messages.to_sentence
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def permitted_role(requested_role)
    return :manager if requested_role == "manager" && current_user.admin?

    :member
  end
end
