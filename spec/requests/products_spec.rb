# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products' do
  describe 'POST /products' do
    let!(:owner) { create(:user) }
    let!(:params) { { title: 'タイトル', price: 10 } }

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
    let!(:owner) { create(:user) }
    let!(:product) { create(:product, user: owner) }

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
  end

  describe 'PATCH /products/{product_id}' do
    let!(:owner) { create(:user) }
    let!(:product) { create(:product, user: owner) }
    let!(:params) { { title: 'edited', price: 50 } }

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
  end

  describe 'DELETE /products/{product_id}' do
    let!(:owner) { create(:user) }
    let!(:product) { create(:product, user: owner) }

    before do
      login(owner)
    end

    # 成功
    it '商品が削除できる' do
      expect do
        delete("/products/#{product.id}")
      end.to change(owner.products, :count).by(-1)
         .and change(owner.deleted_products, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    # 失敗
    it '所有していない商品を削除しようとしたとき' do
      another_owner = create(:user)
      another_product = create(:product, user: another_owner)

      expect do
        delete("/products/#{another_product.id}")
      end.to not_change(another_owner.products, :count)
         .and not_change(another_owner.deleted_products, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /products', elasticsearch: true do
    let!(:owner) { create(:user) }
    let!(:product) { create(:product, user: owner) }

    before do
      Product.import(refresh: true)
    end

    # 成功
    it '取得できる' do
      get('/products')
      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq({
                          products: [
                            {
                              id: product.id,
                              title: product.title,
                              price: product.price,
                              availability_status: product.availability_status
                            }
                          ],
                          meta: {
                            total_hits: 1
                          }
                        })
    end

    # 失敗
    where(:invalid_per_page) do
      [
        0,
        101
      ]
    end

    with_them do
      it 'ページ表示数が不正な値のとき' do
        get('/products', params: { per: invalid_per_page })
        expect(response).to have_http_status(:bad_request)
        res = JSON.parse(response.body, symbolize_names: true)
        expect(res[:errors]).to eq(
          [
            {
              message: '適切なページ表示数を入れてください'
            }
          ]
        )
      end
    end
  end

  describe 'POST /products/purchase' do
    let!(:owner) { create(:user) }
    let!(:product) { create(:product, user: owner) }
    let!(:user) { create(:user) }
    let!(:params) { { price: product.price } }

    # 成功
    it '商品が購入できる' do
      login(user)
      expect do
        post("/products/#{product.id}/purchase", params:)
      end.to change(Order, :count).by(1)
      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq({
                          id: product.id,
                          price: product.price,
                          title: product.title,
                          availability_status: 'purchased'
                        })
    end

    # 失敗
    it 'すでに購入されているとき' do
      product.update!(availability_status: 'purchased')

      login(user)
      expect do
        post("/products/#{product.id}/purchase", params:)
      end.not_to change(Order, :count)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '購入ができない商品です' }
        ]
      )
    end

    it '自分の商品のとき' do
      login(owner)
      expect do
        post("/products/#{product.id}/purchase", params:)
      end.not_to change(Order, :count)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '購入ができない商品です' }
        ]
      )
    end

    it '閲覧した価格と違ったとき' do
      login(user)
      params[:price] = product.price + 10
      expect do
        post("/products/#{product.id}/purchase", params:)
      end.not_to change(Order, :count)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: '価格が更新されました、最新の価格を確認してください' }
        ]
      )
    end
  end
end
