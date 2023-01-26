# frozen_string_literal: true

module Products
  class Destroy < ActiveInteraction::Base
    object :product

    validate :valid_status

    def execute
      ActiveRecord::Base.transaction do
        product.lock!

        deleted_product = DeletedProduct.new(
          title: product.title,
          price: product.price,
          user: product.user
        )

        errors.merge!(deleted_product.errors) unless deleted_product.save

        product.destroy!
      end
    end

    private

    def valid_status
      errors.add(:base, :cannot_delete_if_purchased) if product.purchased?
    end
  end
end
