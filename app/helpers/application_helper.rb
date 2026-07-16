# frozen_string_literal: true

module ApplicationHelper
  TASK_STATUS_STYLES = {
    "todo" => [ "bg-rose-50 text-rose-700", "bg-rose-500" ],
    "in_progress" => [ "bg-amber-50 text-amber-700", "bg-amber-500" ],
    "done" => [ "bg-emerald-50 text-emerald-700", "bg-emerald-500" ]
  }.freeze

  WORKSPACE_ROLE_STYLES = {
    "Admin" => "bg-violet-50 text-violet-700",
    "Manager" => "bg-emerald-50 text-emerald-700",
    "Member" => "bg-blue-50 text-blue-700"
  }.freeze

  def task_status_styles(task)
    TASK_STATUS_STYLES.fetch(task.status)
  end

  def workspace_role_label(membership)
    return "Admin" if membership.user.admin?

    membership.role.humanize
  end

  def workspace_role_style(membership)
    WORKSPACE_ROLE_STYLES.fetch(workspace_role_label(membership))
  end
end
