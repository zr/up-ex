# frozen_string_literal: true

module ProductSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name "product_#{Rails.env}"

    settings do
      mapping dynamic: false do
        indexes :title, analyzer: :kuromoji, type: :text
        indexes :availability_status, type: :keyword
        indexes :updated_at, type: :keyword
      end
    end

    def as_indexed_json(_options = {})
      as_json(only: %i[title availability_status updated_at])
    end

    # インデックス再生成
    def self.create_index!
      client = __elasticsearch__.client
      begin
        client.indices.delete index: index_name
      rescue StandardError
        nil
      end
      client.indices.create(
        index: index_name,
        body: {
          settings: settings.to_hash,
          mappings: mappings.to_hash
        }
      )
    end

    def self.search(title: '', only_available: false)
      search_param = {
        query: {
          bool: {
            must: {
              match_all: {}
            }
          }
        },
        sort: [updated_at: :desc]
      }
      search_param[:query][:bool][:must] = { match: { title: } } if title.present?
      search_param[:query][:bool][:filter] = { term: { availability_status: 'available' } } if only_available

      __elasticsearch__.search(search_param)
    end
  end
end
