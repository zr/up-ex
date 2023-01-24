# frozen_string_literal: true

class DeletedProduct < ApplicationRecord
  validates :title, presence: true
  validates :price, presence: true

  belongs_to :user
end
