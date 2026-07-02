class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.manager?
        scope.left_joins(:project_memberships)
             .where(
               "projects.creator_id = :id OR project_memberships.user_id = :id",
               id: user.id
             ).distinct
      else
        scope.joins(:project_memberships)
             .where(project_memberships: { user_id: user.id })
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? ||
      record.creator == user ||
      record.users.include?(user)
  end

  def create?
    return false unless user

    user.admin? || user.manager?
  end

  def new?
    create?
  end


  def update?
    user.admin? || record.creator == user
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end