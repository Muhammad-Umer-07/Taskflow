# frozen_string_literal: true

class Task < ApplicationRecord
  TITLE_MAX_LENGTH = 100
  DESCRIPTION_MAX_LENGTH = 500

  belongs_to :project

  belongs_to :assignee,
             class_name: "User",
             optional: true

  enum :status, {
    todo: 0,
    in_progress: 1,
    done: 2
  }, default: :todo

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }, allow_blank: true
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
