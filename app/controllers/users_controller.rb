# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[create]

  def create
    user = User.new(create_params)
    if user.valid?
      user.save!
      render json: user, serializer: UserPrivateSerializer
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
