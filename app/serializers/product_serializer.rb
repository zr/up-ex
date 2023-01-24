# frozen_string_literal: true

class ProductSerializer < ActiveModel::Serializer
  type 'product'
  attributes %i[id title price availability_status]
end
