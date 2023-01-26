# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~]{6,}+\z/
  validates :email, uniqueness: true, presence: true,
                    format: { with: VALID_EMAIL_REGEX, message: :invalid_email }
  validates :password, confirmation: true, on: :create,
                       format: { with: VALID_PASSWORD_REGEX, message: :invalid_password }
  validates :password_confirmation, presence: true, on: :create
  validates :point, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :products, dependent: :restrict_with_exception
  has_many :deleted_products, dependent: :restrict_with_exception
  has_many :order, dependent: :restrict_with_exception

  before_create do
    self.point = 10_000
  end
end
