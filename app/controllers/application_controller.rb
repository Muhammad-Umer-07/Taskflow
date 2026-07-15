# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern, unless: -> { Rails.env.test? }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def record_not_found
    redirect_to root_path, alert: "The requested resource could not be found."
  end

  def user_not_authorized
    redirect_to(request.referrer || root_path, alert: "You are not authorized to perform this action.")
  end
end
