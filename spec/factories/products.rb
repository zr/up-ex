# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:title) { |n| "#{n}_product_title" }
    price { 10 }

    association :user
  end
end
