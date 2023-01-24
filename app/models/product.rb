# frozen_string_literal: true

class Product < ApplicationRecord
  extend Enumerize

  validates :title, presence: true
  validates :price, presence: true
  validate :valid_price

  belongs_to :user

  enumerize :availability_status, in: %i[available purchased], default: :available, predicates: true

  private

  def valid_price
    errors.add(:price, :invalid_price) if price.nil? || price < 1 || price > 1_000_000
  end
end
