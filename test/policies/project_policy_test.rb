require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @manager = users(:two)
    @member = users(:three)

    @admin_project = projects(:one)
    @manager_project = projects(:two)
  end

  def test_scope
    admin_scope = ProjectPolicy::Scope.new(@admin, Project.all).resolve
    assert_includes admin_scope, @admin_project
    assert_includes admin_scope, @manager_project

    manager_scope = ProjectPolicy::Scope.new(@manager, Project.all).resolve
    assert_includes manager_scope, @manager_project
    assert_not_includes manager_scope, @admin_project

    member_scope = ProjectPolicy::Scope.new(@member, Project.all).resolve
    assert_includes member_scope, @manager_project
    assert_not_includes member_scope, @admin_project
  end

  def test_show
    assert ProjectPolicy.new(@admin, @manager_project).show?
    assert ProjectPolicy.new(@manager, @manager_project).show?
    assert_not ProjectPolicy.new(@manager, @admin_project).show?
    assert ProjectPolicy.new(@member, @manager_project).show?
    assert_not ProjectPolicy.new(@member, @admin_project).show?
  end

  def test_create
    assert ProjectPolicy.new(@admin, Project.new).create?
    assert ProjectPolicy.new(@manager, Project.new).create?
    assert_not ProjectPolicy.new(@member, Project.new).create?
  end

  def test_update
    assert ProjectPolicy.new(@admin, @manager_project).update?
    assert ProjectPolicy.new(@manager, @manager_project).update?
    assert_not ProjectPolicy.new(@manager, @admin_project).update?
    assert_not ProjectPolicy.new(@member, @manager_project).update?
  end

  def test_destroy
    assert ProjectPolicy.new(@admin, @manager_project).destroy?
    assert ProjectPolicy.new(@manager, @manager_project).destroy?
    assert_not ProjectPolicy.new(@manager, @admin_project).destroy?
    assert_not ProjectPolicy.new(@member, @manager_project).destroy?
  end
end
