class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    admin: 0,
    manager: 1,
    member: 2
  }


has_many :project_memberships,
  dependent: :destroy

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

end
