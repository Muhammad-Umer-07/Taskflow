class RestoreEnumDefaults < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :role, from: nil, to: 2
    change_column_default :project_memberships, :role, from: nil, to: 1
    change_column_default :tasks, :status, from: nil, to: 0
  end
end
