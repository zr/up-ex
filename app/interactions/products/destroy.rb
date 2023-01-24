# frozen_string_literal: true

module Products
  class Destroy < ActiveInteraction::Base
    object :product

    validate :valid_status

    def execute
      product.update!(availability_status: 'deleted')
    end

    private

    def valid_status
      errors.add(:base, :cannot_delete_if_purchased) if product.purchased?
    end
  end
end
