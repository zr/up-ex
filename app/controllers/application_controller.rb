# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_csrf_cookie
  before_action :require_login
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ApplicationError::UnauthorizedError, with: :not_autherized

  protected

  def render_validation_errors(model)
    errors = model.errors.full_messages.map do |message|
      { message: }
    end
    render json: { errors: }, status: :bad_request
  end

  def render_base_errors(errors)
    errors = [errors] if errors.is_a?(String)
    render json: { errors: errors.map { |e| { message: e } } }, status: :bad_request
  end

  def not_authenticated
    head :unauthorized
  end

  def not_autherized
    head :forbidden
  end

  def not_found
    head :not_found
  end

  def set_csrf_cookie
    cookies['CSRF-TOKEN'] = form_authenticity_token
  end
end
