# frozen_string_literal: true

class UserPublicSerializer < ActiveModel::Serializer
  type 'user'
  attributes %i[id]
end
