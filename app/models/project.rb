# frozen_string_literal: true

class Project < ApplicationRecord
  TITLE_MAX_LENGTH = 100
  DESCRIPTION_MAX_LENGTH = 1000

  belongs_to :creator, class_name: "User"

  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, uniqueness: { scope: :creator_id, message: "should be unique per user" }
  validates :title, length: { maximum: TITLE_MAX_LENGTH }
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }, allow_blank: true

  after_create :add_creator_as_manager

  private

  def add_creator_as_manager
    project_memberships.create!(
      user: creator,
      role: :manager
    )
  end
end
