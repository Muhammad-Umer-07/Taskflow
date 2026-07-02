class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :role, {
    manager: 0,
    member: 1
  }

  validates :user_id, uniqueness: {
    scope: :project_id,
    message: "is already a member of this project"
  }
end