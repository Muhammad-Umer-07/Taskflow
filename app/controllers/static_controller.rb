# frozen_string_literal: true

class StaticController < ApplicationController
  def home
    render "home/index"
  end
end
