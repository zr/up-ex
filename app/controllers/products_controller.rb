# frozen_string_literal: true

class ProductsController < ApplicationController
  skip_before_action :require_login, only: %i[index show]

  def index
    product_index = ::Products::Index.run(index_params)
    if product_index.valid?
      search_result = product_index.result
      render json: search_result[:products], each_serializer: ProductSerializer,
             meta: { total_hits: search_result[:total_hits] },
             adapter: :json
    else
      render_validation_errors(product_index)
    end
  end

  def show
    load_product
    render json: @product, serializer: ProductSerializer
  end

  def create
    input = { user: current_user }.merge(create_params)
    product = Product.new(input)
    if product.valid?
      product.save!
      render json: product, serializer: ProductSerializer
    else
      render_validation_errors(product)
    end
  end

  def update
    load_product
    valid_owner
    input = { product: @product }.merge(update_params)
    product_update = ::Products::Update.run(input)
    if product_update.valid?
      product = product_update.result
      render json: product, serializer: ProductSerializer
    else
      render_validation_errors(product_update)
    end
  end

  def destroy
    load_product
    valid_owner
    product_destroy = ::Products::Destroy.run({ product: @product })
    if product_destroy.valid?
      head :ok
    else
      render_validation_errors(product_destroy)
    end
  end

  def purchase
    load_product
    input = { user: current_user, product: @product }.merge(purchase_params)
    product_purchase = ::Products::Purchase.run(input)
    if product_purchase.valid?
      product = product_purchase.result
      render json: product, serializer: ProductSerializer
    else
      render_validation_errors(product_purchase)
    end
  end

  private

  def index_params
    params.permit(
      :search_term,
      :only_available,
      :page,
      :per
    )
  end

  def create_params
    params.permit(
      :title,
      :price
    )
  end

  def update_params
    params.permit(
      :title,
      :price
    )
  end

  def purchase_params
    params.permit(
      :price
    )
  end

  def load_product
    @product = Product.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound if @product.nil?
  end

  def valid_owner
    raise ApplicationError::UnauthorizedError if @product.user != current_user
  end
end
