# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~]{6,}+\z/
  validates :email, uniqueness: true, presence: true,
                    format: { with: VALID_EMAIL_REGEX, message: :invalid_email }
  validates :password, confirmation: true,
                       format: { with: VALID_PASSWORD_REGEX, message: :invalid_password }
  validates :password_confirmation, presence: true
  validates :point, presence: true

  has_many :products, dependent: :restrict_with_exception
end
