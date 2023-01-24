# frozen_string_literal: true

class UserPrivateSerializer < ActiveModel::Serializer
  type 'user'
  attributes %i[id email point]
end
