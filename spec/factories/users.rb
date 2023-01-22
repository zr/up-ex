# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}@exeample.com" }
    password { 'Passw0rd' }
    password_confirmation { 'Passw0rd' }
  end
end
