require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "admin can list and update users" do
    policy = UserPolicy.new(users(:admin), users(:member))

    assert_predicate policy, :index?
    assert_predicate policy, :update?
    assert_predicate policy, :destroy?
  end

  test "manager cannot list or update users" do
    policy = UserPolicy.new(users(:manager), users(:member))

    assert_not_predicate policy, :index?
    assert_not_predicate policy, :update?
    assert_not_predicate policy, :destroy?
  end
end
