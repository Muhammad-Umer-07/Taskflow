# frozen_string_literal: true

class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :role, {
    manager: 0,
    member: 1
  }, default: :member

  validates :user_id, uniqueness: {
    scope: :project_id,
    message: "is already a member of this project"
  }

  before_destroy :keep_creator_membership
  before_destroy :unassign_project_tasks

  private

  def keep_creator_membership
    return unless project.creator_id == user_id

    errors.add(:base, "The project creator cannot be removed from the project")
    throw :abort
  end

  def unassign_project_tasks
    project.tasks.where(assignee_id: user_id).update_all(assignee_id: nil)
  end
end
