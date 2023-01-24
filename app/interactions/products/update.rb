# frozen_string_literal: true

module Products
  class Update < ActiveInteraction::Base
    object :product
    string :title, default: nil
    integer :price, default: nil

    validate :valid_status

    def execute
      product.title = title if title.present?
      product.price = price if price.present?

      errors.merge!(product.errors) unless product.save

      product
    end

    private

    def valid_status
      errors.add(:base, :cannot_update_if_purchased) if product.purchased?
    end
  end
end
