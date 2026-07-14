# frozen_string_literal: true

class StaticController < ApplicationController
  def home
    if user_signed_in?
      @projects = policy_scope(Project).includes(:creator)
      @assigned_tasks = current_user.assigned_tasks.where.not(status: :done).includes(:project)
    end
  end
end
