# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  describe 'POST /users' do
    let!(:params) { { email: 'test@test.com', password: 'Passw0rd', password_confirmation: 'Passw0rd' } }

    # 成功
    it 'ユーザー作成ができる' do
      post('/users', params:)
      expect(response).to have_http_status(:ok)
      user = User.find_by(email: params[:email])
      expect(user).to be_present
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(
        {
          id: user.id,
          email: params[:email],
          point: user.point
        }
      )
    end

    # 失敗
    it 'メールアドレスが既に登録されていたとき' do
      another_user = create(:user)
      params[:email] = another_user.email
      post('/users', params:)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: 'メールアドレスはすでに存在します' }
        ]
      )
    end

    it 'メールアドレスが指定されていないとき' do
      params[:email] = ''
      post('/users', params:)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: 'メールアドレスを入力してください' },
          { message: 'メールアドレスの形式を確認してください' }
        ]
      )
    end

    it 'パスワードが指定されていないとき' do
      params[:password] = ''
      post('/users', params:)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: 'パスワード(確認)とパスワードの入力が一致しません' },
          { message: 'パスワードは6文字以上・半角英数字(大文字小文字)を1文字以上入れてください' }
        ]
      )
    end

    it 'パスワードとパスワード(確認)が一致しないとき' do
      params[:password_confirmation] += 'a'
      post('/users', params:)
      expect(response).to have_http_status(:bad_request)
      res = JSON.parse(response.body, symbolize_names: true)
      expect(res[:errors]).to eq(
        [
          { message: 'パスワード(確認)とパスワードの入力が一致しません' }
        ]
      )
    end
  end
end
