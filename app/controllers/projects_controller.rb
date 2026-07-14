# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = policy_scope(Project)
                 .includes(:users, :tasks)
  end

  def show
    authorize @project
<<<<<<< Updated upstream
=======
    @tasks = @project.tasks.includes(:assignee)
    @available_members = User.member.where.not(id: @project.users.select(:id)).order(:email)
>>>>>>> Stashed changes
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = current_user.created_projects.build(project_params)
    authorize @project

    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy

    redirect_to projects_path, notice: "Project deleted successfully."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end