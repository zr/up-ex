# frozen_string_literal: true

module Products
  class Purchase < ActiveInteraction::Base
    object :user
    object :product
    integer :price

    validate :not_owner
    validate :available_product
    validate :valid_price

    def execute
      ActiveRecord::Base.transaction do
        product.update!(availability_status: 'purchased')

        Order.create!(
          product_id: product.id,
          buyer_id: user.id,
          seller_id: product.user_id
        )

        product
      end
    end

    private

    def not_owner
      errors.add(:base, :unpurchasable_product) if user.id == product.user_id
    end

    def available_product
      errors.add(:base, :unpurchasable_product) unless product.available?
    end

    def valid_price
      errors.add(:base, :invalid_asked_price) unless price == product.price
    end
  end
end
