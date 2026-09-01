# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:project).left_joins(project: :project_memberships)
             .where("projects.creator_id = :id OR project_memberships.user_id = :id", id: user.id)
             .distinct
      end
    end
  end

  def index?
    user.admin? || record.project.creator == user || project_member?
  end

  def show?
    user.admin? ||
      record.project.creator == user ||
      project_member?
  end

  def create?
    return false unless user
    user.admin? ||
      record.project.creator == user ||
      record.project.project_memberships.exists?(user: user, role: :manager)
  end

  def new?
    create?
  end

  def update?
    return false unless user
    user.admin? ||
      record.project.creator == user ||
      record.project.project_memberships.exists?(user: user, role: :manager) ||
      record.assignee == user
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user
    user.admin? ||
      record.project.creator == user ||
      record.project.project_memberships.exists?(user: user, role: :manager)
  end

  def permitted_attributes
    if user.admin? || record.project.creator == user ||
       record.project.project_memberships.exists?(user: user, role: :manager)
      [ :title, :description, :status, :assignee_id ]
    elsif record.assignee == user
      [ :status ]
    else
      []
    end
  end

  private

  def project_member?
    record.project.project_memberships.exists?(user_id: user.id)
  end
end
