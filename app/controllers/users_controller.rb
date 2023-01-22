# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[create]

  def create
    user = User.new(create_params)
    if user.valid?
      user.point += 10_000
      user.save!
      render json: user, only: %i[id email point]
    else
      render_validation_errors(user)
    end
  end

  private

  def create_params
    params.permit(
      :email,
      :password,
      :password_confirmation
    )
  end
end
