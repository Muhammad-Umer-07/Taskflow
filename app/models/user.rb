# frozen_string_literal: true

class User < ApplicationRecord
  EMAIL_ADDRESS = /\A(?!\.)(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+\/?^_`{|}~-]+(?<!\.)@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+\z/
  PASSWORD_COMPLEXITY = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+\z/

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    admin: 0,
    manager: 1,
    member: 2
  }

<<<<<<< Updated upstream

has_many :project_memberships,
  dependent: :destroy
=======
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :created_projects, class_name: "Project", foreign_key: :creator_id, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships

  validates :email, length: { maximum: 255 }, format: { with: EMAIL_ADDRESS, message: "must be a valid email address" }
  validate :password_complexity
>>>>>>> Stashed changes

has_many :projects,
  through: :project_memberships

has_many :created_projects,
  class_name: "Project",
  foreign_key: :creator_id,
  dependent: :destroy

has_many :assigned_tasks,
  class_name: "Task",
  foreign_key: :assignee_id,
  dependent: :nullify

<<<<<<< Updated upstream
=======
  def password_complexity
    return if password.blank?
    return if password.match?(PASSWORD_COMPLEXITY)

    errors.add(:password, "must include at least one uppercase letter, one lowercase letter, one number, and one symbol")
  end
>>>>>>> Stashed changes
end
