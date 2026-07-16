# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy]

  def index
    authorize @project, :show?
    @tasks = @project.tasks
                     .includes(:assignee)
  end

  def show
    authorize @task
  end

  def new
    @task = @project.tasks.new
    authorize @task
  end

  def create
    @task = @project.tasks.new(task_params)
    authorize @task

    if @task.save
      redirect_to project_path(@project),
                  notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @task
  end

  def update
    authorize @task

    if @task.update(task_params)
      redirect_to project_tasks_path(@project),
                  notice: "Task updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task

    @task.destroy

    redirect_to project_tasks_path(@project),
                notice: "Task deleted successfully."
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    return if @project

    redirect_to projects_path, alert: "The requested project could not be found."
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    task_for_policy = @task || Task.new(project: @project)
    params.require(:task).permit(policy(task_for_policy).permitted_attributes)
  end
end
