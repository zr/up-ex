# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :product, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
