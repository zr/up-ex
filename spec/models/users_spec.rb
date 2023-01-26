# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'User#Validation' do
    let!(:params) { { email: 'email@email.com', password: 'Passw0wd', password_confirmation: 'Passw0wd' } }

    # 成功
    it '正しいメールとパスワードの場合、保存ができる' do
      user = described_class.new(email: params[:email], password: params[:password],
                                 password_confirmation: params[:password_confirmation])
      expect(user).to be_valid
    end

    # 失敗
    where(:invalid_email) do
      [
        ['example'],
        ['example@'],
        ['example.com'],
        ['example@example.'],
        ['@example.com'],
        ['@.com']
      ]
    end

    with_them do
      it 'メールアドレスの形式が間違っている場合、保存できない' do
        user = described_class.new(email: invalid_email, password: params[:password],
                                   password_confirmation: params[:password_confirmation])
        expect(user).to be_invalid
      end
    end

    where(:invalid_password) do
      [
        ['a'],
        ['AAaa1'],
        ['AAaabb'],
        ['aabb11'],
        ['AABB11'],
        ['AAaa11あ']
      ]
    end

    with_them do
      it 'パスワードの形式が間違っている場合、保存できない' do
        user = described_class.new(email: params[:email], password: invalid_password,
                                   password_confirmation: invalid_password)
        expect(user).to be_invalid
      end
    end

    it 'パスワードと確認のパスワードが違う場合、保存できない' do
      user = described_class.new(email: params[:email], password: params[:password],
                                 password_confirmation: "#{params[:password]}a")
      expect(user).to be_invalid
    end

    it 'ポイントがマイナスの場合、保存できない' do
      user = described_class.new(email: params[:email], password: params[:password],
                                 password_confirmation: params[:password_confirmation], point: -1)
      expect(user).to be_invalid
    end
  end

  describe 'User#Callback' do
    let!(:params) { { email: 'email@email.com', password: 'Passw0wd', password_confirmation: 'Passw0wd' } }

    it 'ユーザー作成時にポイントを10000ポイント持っている' do
      user = described_class.create(email: params[:email], password: params[:password],
                                    password_confirmation: params[:password_confirmation])
      expect(user.point).to eq(10_000)
    end
  end
end
