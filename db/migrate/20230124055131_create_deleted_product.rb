# frozen_string_literal: true

class CreateDeletedProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :deleted_products do |t|
      t.string :title, null: false
      t.integer :price, null: false
      t.timestamps
    end
    add_reference :deleted_products, :user, foreign_key: true
  end
end
