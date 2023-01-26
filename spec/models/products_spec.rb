# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product do
  describe 'Product#Validation' do
    let!(:params) { { title: 'title', price: 10 } }
    let!(:user) { create(:user) }

    # 成功
    it '正しいタイトルと価格の場合、保存できる' do
      product = described_class.new(title: params[:title], price: params[:price], user:)
      expect(product).to be_valid
    end

    where(:invalid_price) do
      [
        0,
        1_000_001
      ]
    end

    with_them do
      it '価格が範囲外の場合、保存できない' do
        product = described_class.new(title: params[:title], price: invalid_price, user:)
        expect(product).to be_invalid
      end
    end
  end
end
