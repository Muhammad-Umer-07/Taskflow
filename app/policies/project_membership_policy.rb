# frozen_string_literal: true

class ProjectMembershipPolicy < ApplicationPolicy
  def create?
    manage_members?
  end

  def destroy?
    manage_members? && record.user_id != project.creator_id
  end

  private

  def manage_members?
    user.present? && (
      user.admin? ||
      project.creator == user ||
      project.project_memberships.exists?(user: user, role: :manager)
    )
  end

  def project
    record.project
  end
end
