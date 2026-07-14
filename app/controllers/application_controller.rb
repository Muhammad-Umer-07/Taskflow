# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

<<<<<<< Updated upstream
=======
  allow_browser versions: :modern, unless: -> { Rails.env.test? }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
>>>>>>> Stashed changes
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def record_not_found
    redirect_to root_path, alert: "The requested resource could not be found."
  end

  def user_not_authorized
<<<<<<< Updated upstream
    redirect_to root_path, alert: "You are not authorized to perform this action."
=======
    redirect_to(request.referrer || root_path, alert: "You are not authorized to perform this action.")
>>>>>>> Stashed changes
  end
end