# frozen_string_literal: true

module Products
  class Index < ActiveInteraction::Base
    string :search_term, default: ''
    boolean :only_available, default: false
    integer :page, default: 0
    integer :per, default: 10

    validate :valid_size

    def execute
      product = Product.search(
        title: search_term,
        only_available:
      ).page(page).per_page(per).records

      {
        total_hits: product.total_entries,
        products: product
      }
    end

    def valid_size
      errors.add(:base, :invalid_search_size) if per < 1 || per > 100
    end
  end
end
