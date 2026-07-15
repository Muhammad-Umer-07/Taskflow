class AllowTasksWithoutAssignees < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :assignee_id, true
  end
end
