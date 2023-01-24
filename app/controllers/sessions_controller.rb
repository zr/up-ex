# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[create]

  def show
    user = current_user
    render json: user, serializer: UserPrivateSerializer
  end

  def create
    @user = login(create_params[:email], create_params[:password])
    if @user.present?
      head :ok
    else
      render_base_errors('ログインに失敗しました')
    end
  end

  def destroy
    logout
    head :ok
  end

  private

  def create_params
    params.permit(
      :email,
      :password
    )
  end

  def form_authenticity_token; end
end
