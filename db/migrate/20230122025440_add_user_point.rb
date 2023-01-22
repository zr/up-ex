# frozen_string_literal: true

class AddUserPoint < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :point, :integer, null: false, default: 0
  end
end
