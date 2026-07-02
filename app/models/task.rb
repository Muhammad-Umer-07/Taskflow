class Task < ApplicationRecord
  belongs_to :project

  belongs_to :assignee,
             class_name: "User"

  enum :status, {
    todo: 0,
    in_progress: 1,
    done: 2
  }

  validates :title, presence: true
  validate :assignee_must_be_project_member

  scope :completed, -> { where(status: :done) }
  scope :assigned_to, ->(user) { where(assignee: user) }

  private

  def assignee_must_be_project_member
    if project.present? && assignee.present? && !project.users.include?(assignee)
      errors.add(:assignee, "must be a member of the project")
    end
  end
end