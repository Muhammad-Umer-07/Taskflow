require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "defaults role to member" do
    user = User.create!(email: "default-role@example.com", password: "Password1!", password_confirmation: "Password1!")

    assert_equal "member", user.role
  end

  test "requires a valid email address" do
    user = User.new(email: "invalid", password: "Password1!")

    assert_not user.valid?
    assert_includes user.errors[:email], "must be a valid email address"
  end

  test "accepts a valid public email address" do
    user = User.new(email: "user.name+tag@example.co.uk", password: "Password1!")

    assert_predicate user, :valid?
  end

  test "rejects email addresses without a public domain" do
    [ "user@example", "user@localhost", "user@example..com" ].each do |email|
      user = User.new(email: email, password: "Password1!")

      assert_not user.valid?, "Expected #{email} to be invalid"
      assert_includes user.errors[:email], "must be a valid email address"
    end
  end

  test "requires a password with at least eight characters" do
    user = User.new(email: "new@example.com", password: "short")

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "requires an uppercase letter in the password" do
    user = User.new(email: "new@example.com", password: "password1!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
  end

  test "requires a lowercase letter in the password" do
    user = User.new(email: "new@example.com", password: "PASSWORD1!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
  end

  test "requires a number in the password" do
    user = User.new(email: "new@example.com", password: "Password!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
  end

  test "requires a symbol in the password" do
    user = User.new(email: "new@example.com", password: "Password1")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
  end

  test "accepts a password with uppercase, lowercase, number, and symbol" do
    user = User.new(email: "new@example.com", password: "Password1!")

    assert_predicate user, :valid?
  end
end
