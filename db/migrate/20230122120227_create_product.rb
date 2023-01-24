# frozen_string_literal: true

class CreateProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.integer :price, null: false
      t.string :availability_status, null: false
      t.timestamps
    end
    add_reference :products, :user, foreign_key: true
  end
end
