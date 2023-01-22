# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'POST /session' do
    let(:password) { 'PassW0rd' }
    let(:user) { create(:user, password:, password_confirmation: password) }
    let(:params) { { email: user.email, password: } }

    # 成功
    it 'ログインできる' do
      post('/session', params:)
      expect(response).to have_http_status(:ok)
    end

    # 失敗
    it 'ログインできない' do
      params[:password] += 'a'
      post('/session', params:)
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'DELETE /session' do
    let(:user) { create(:user) }

    it 'ログアウトできる' do
      login(user)
      delete '/session'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /session' do
    let(:user) { create(:user) }

    # 成功
    it 'ユーザー情報を取得できる' do
      login(user)
      get '/session'
      expect(response).to have_http_status(:ok)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res).to eq({
                          id: user.id,
                          email: user.email,
                          point: user.point
                        })
    end

    # 失敗
    it 'ログインしていないとき' do
      get '/session'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
