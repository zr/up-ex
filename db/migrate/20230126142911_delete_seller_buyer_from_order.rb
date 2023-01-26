# frozen_string_literal: true

class DeleteSellerBuyerFromOrder < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :orders, :users
    remove_index :orders, :seller_id
    remove_column :orders, :seller_id, :bigint
    remove_index :orders, :buyer_id
    remove_column :orders, :buyer_id, :bigint
    add_reference :orders, :user, foreign_key: true
  end
end
