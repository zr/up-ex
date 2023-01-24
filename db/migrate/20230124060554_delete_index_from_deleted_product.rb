# frozen_string_literal: true

class DeleteIndexFromDeletedProduct < ActiveRecord::Migration[7.0]
  def change
    remove_index :deleted_products, :user_id
  end
end
