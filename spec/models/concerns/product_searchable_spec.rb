# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductSearchable, elasticsearch: true do
  describe '商品の検索' do
    def search_product_ids(title: '', only_available: false)
      Product.search(title:, only_available:).records.pluck(:id)
    end

    describe 'タイトルの検索' do
      let!(:product1) { create(:product, title: 'マグマと水の作り方') }
      let!(:product2) { create(:product, title: 'メガネの使い方') }
      let!(:product3) { create(:product, title: 'マグマの使い方') }

      before do
        Product.import(refresh: true)
      end

      it '空白だと全てにマッチする' do
        expect(search_product_ids(title: '').sort).to eq([product1.id, product2.id, product3.id].sort)
      end

      it '1つの単語が1つのタイトルにマッチする' do
        expect(search_product_ids(title: '水').sort).to eq([product1.id])
      end

      # TODO: Refactor multi-word single-match
      # it '複数の単語が1つのタイトルにマッチする' do
      #   expect(search_product_ids('メガネ 使い方').sort).to eq([product2.id].sort)
      # end

      it '1つの単語が複数のタイトルにマッチする' do
        expect(search_product_ids(title: '使い方').sort).to eq([product2.id, product3.id].sort)
      end

      it '複数の単語が複数のタイトルにマッチする' do
        expect(search_product_ids(title: 'マグマ 使い方').sort).to eq([product1.id, product2.id, product3.id].sort)
      end
    end

    describe '利用可能ステータスの絞り込み' do
      let!(:product1) { create(:product, availability_status: :available) }
      let!(:product2) { create(:product, availability_status: :available) }
      let!(:product3) { create(:product, availability_status: :purchased) }

      before do
        Product.import(refresh: true)
      end

      it 'falseを指定すると利用可能ステータス関わらず全てを取得する' do
        expect(search_product_ids(only_available: false).sort).to eq([product1.id, product2.id, product3.id].sort)
      end

      it 'trueを指定すると利用可能な商品のみを取得する' do
        expect(search_product_ids(only_available: true).sort).to eq([product1.id, product2.id].sort)
      end
    end
  end
end
