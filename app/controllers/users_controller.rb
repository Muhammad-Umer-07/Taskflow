# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[update destroy]

  def index
    authorize User
    @users = policy_scope(User).order(:email)
  end

  def update
    authorize @user
    role = params.dig(:user, :role)

    unless User.roles.key?(role)
      redirect_to users_path, alert: "Please select a valid role."
      return
    end

    @user.role = role

    if @user.save
      redirect_to users_path, notice: "User role updated successfully."
    else
      redirect_to users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @user

    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account."
      return
    end

    @user.destroy!
    redirect_to users_path, notice: "User deleted successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
