# frozen_string_literal: true

module Products
  class Purchase < ActiveInteraction::Base
    object :user
    object :product
    integer :price

    validate :not_owner
    validate :available_product
    validate :valid_asked_price
    validate :not_enough_point

    def execute
      ActiveRecord::Base.transaction do
        product.lock!
        product.update!(availability_status: 'purchased')

        user.point -= product.price
        user.save!

        order = product.build_order(
          user:
        )
        order.save!

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

    def valid_asked_price
      errors.add(:base, :invalid_asked_price) unless price == product.price
    end

    def not_enough_point
      errors.add(:base, :not_enough_point) if (user.point - product.price).negative?
    end
  end
end
