# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :require_login

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

  def not_found
    head :not_found
  end
end
