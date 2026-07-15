class HardenDataIntegrity < ActiveRecord::Migration[8.1]
  def change
    change_column_null :projects, :creator_id, false
    change_column_null :projects, :title, false
    change_column_null :tasks, :title, false
    change_column_null :tasks, :status, false
    change_column_null :users, :role, false
    change_column_null :project_memberships, :role, false

    add_index :projects, :creator_id
    add_index :tasks, :assignee_id
    add_index :project_memberships, %i[user_id project_id], unique: true

    add_foreign_key :projects, :users, column: :creator_id
    add_foreign_key :tasks, :users, column: :assignee_id
  end
end
