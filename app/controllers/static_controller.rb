# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    render "home/index"
  end
end
