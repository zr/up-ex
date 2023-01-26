# frozen_string_literal: true

class Product < ApplicationRecord
  extend Enumerize
  include ProductSearchable

  validates :title, presence: true
  validates :price, presence: true
  validate :valid_price

  belongs_to :user
  has_one :order, dependent: :restrict_with_exception

  enumerize :availability_status, in: %i[available purchased], default: :available, predicates: true

  private

  def valid_price
    errors.add(:price, :invalid_price) if price.nil? || price < 1 || price > 1_000_000
  end
end
