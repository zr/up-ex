# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products' do
  describe 'POST /products' do
    let(:owner) { create(:user) }
    let(:params) { { title: 'タイトル', price: 10 } }

    before do
      login(owner)
    end

    # 成功
    it '商品が作成できる' do
      expect do
        post('/products', params:)
      end.to change(owner.products, :count).by(1)
      product = Product.find_by(user: owner, title: params[:title], price: params[:price])
      expect(product).to be_present

      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq(
        {
          id: product.id,
          title: params[:title],
          price: params[:price],
          availability_status: 'available'
        }
      )
    end

    # 失敗
    it 'タイトルを指定していないとき' do
      params[:title] = ''
      expect do
        post('/products', params:)
      end.not_to change(owner.products, :count)

      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: 'タイトルを入力してください' }
        ]
      )
    end

    it '価格を指定していないとき' do
      params[:price] = ''
      expect do
        post('/products', params:)
      end.not_to change(owner.products, :count)

      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '価格を入力してください' },
          { message: '価格は1ポイント以上・1,000,000以下で入れてください' }
        ]
      )
    end

    where(:invalid_price) do
      [
        0,
        1_000_001
      ]
    end

    with_them do
      it '価格が不正な値のとき' do
        params[:price] = invalid_price
        expect do
          post('/products', params:)
        end.not_to change(owner.products, :count)

        expect(response).to have_http_status(:bad_request)
        res = JSON.parse(response.body, symbolize_names: true)
        expect(res[:errors]).to eq(
          [
            { message: '価格は1ポイント以上・1,000,000以下で入れてください' }
          ]
        )
      end
    end
  end

  describe 'GET /products/{product_id}' do
    let(:owner) { create(:user) }
    let(:product) { create(:product, user: owner) }

    # 成功
    it '商品の情報が取得できる' do
      get("/products/#{product.id}")
      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq(
        {
          id: product.id,
          title: product.title,
          price: product.price,
          availability_status: product.availability_status
        }
      )
    end

    # 失敗
    it '存在しない商品を指定したとき' do
      get('/products/invalid_product')
      expect(response).to have_http_status(:not_found)
    end

    it '削除済みの商品を指定したとき' do
      product.update!(availability_status: 'deleted')
      get("/products/#{product.id}")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /products/{product_id}' do
    let(:owner) { create(:user) }
    let(:product) { create(:product, user: owner) }
    let(:params) { { title: 'edited', price: 50 } }

    before do
      login(owner)
    end

    # 成功
    it '商品の情報が編集できる' do
      patch("/products/#{product.id}", params:)
      product.reload
      expect(product.title).to eq(params[:title])
      expect(product.price).to eq(params[:price])

      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq(
        {
          id: product.id,
          title: params[:title],
          price: params[:price],
          availability_status: product.availability_status
        }
      )
    end

    # 失敗
    it '所有していない商品を編集しようとしたとき' do
      another_owner = create(:user)
      another_product = create(:product, user: another_owner)
      patch("/products/#{another_product.id}", params:)
      another_product.reload
      expect(another_product.title).not_to eq(params[:title])
      expect(another_product.price).not_to eq(params[:price])

      expect(response).to have_http_status(:forbidden)
    end

    it '購入済みの商品を編集しようとしたとき' do
      product.update!(availability_status: 'purchased')

      patch("/products/#{product.id}", params:)
      product.reload
      expect(product.title).not_to eq(params[:title])
      expect(product.price).not_to eq(params[:price])

      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '購入済みの商品は編集できません' }
        ]
      )
    end

    it '削除済みの商品を編集しようとしたとき' do
      product.update!(availability_status: 'deleted')

      patch("/products/#{product.id}", params:)
      product.reload
      expect(product.title).not_to eq(params[:title])
      expect(product.price).not_to eq(params[:price])

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /products/{product_id}' do
    let(:owner) { create(:user) }
    let(:product) { create(:product, user: owner) }

    before do
      login(owner)
    end

    # 成功
    it '商品が削除できる' do
      delete("/products/#{product.id}")
      expect(product.reload.availability_status).to eq('deleted')

      expect(response).to have_http_status(:ok)
    end

    # 失敗
    it '所有していない商品を削除しようとしたとき' do
      another_owner = create(:user)
      another_product = create(:product, user: another_owner)

      delete("/products/#{another_product.id}")
      expect(another_product.reload.availability_status).not_to eq('deleted')

      expect(response).to have_http_status(:forbidden)
    end

    it '購入済みの商品を削除しようとしたとき' do
      product.update!(availability_status: 'purchased')

      delete("/products/#{product.id}")
      expect(product.reload.availability_status).not_to eq('deleted')

      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '購入済みの商品は削除できません' }
        ]
      )
    end
  end
end
