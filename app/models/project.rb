class Project < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, uniqueness: { scope: :creator_id, message: "should be unique per user" }
  validates :description, presence: true

  after_create :add_creator_as_manager

  private

  def add_creator_as_manager
    project_memberships.create!(
      user: creator,
      role: :manager
    )
  end
end