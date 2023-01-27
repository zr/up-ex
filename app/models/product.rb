# frozen_string_literal: true

class Product < ApplicationRecord
  extend Enumerize
  include ProductSearchable

  validates :title, presence: true
  validates :price, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 1_000_000,
    message: :invalid_price
  }

  belongs_to :user
  has_one :order, dependent: :restrict_with_exception

  enumerize :availability_status, in: %i[available purchased], default: :available, predicates: true
end
