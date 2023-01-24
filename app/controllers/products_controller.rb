# frozen_string_literal: true

class ProductsController < ApplicationController
  skip_before_action :require_login, only: %i[show]

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

  private

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

  def load_product
    @product = Product.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound if @product.nil?
  end

  def valid_owner
    raise ApplicationError::UnauthorizedError if @product.user != current_user
  end
end
