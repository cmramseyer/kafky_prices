class PricingProductsController < ApplicationController
  before_action :set_pricing_product, only: %i[show edit update destroy]

  def index
    @pricing_products = PricingProduct.order(:sku)
  end

  def show
  end

  def new
    @pricing_product = PricingProduct.new
  end

  def edit
  end

  def create
    @pricing_product = PricingProduct.new(pricing_product_params)

    if @pricing_product.save
      redirect_to @pricing_product, notice: "Product was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pricing_product.update(pricing_product_params)
      redirect_to @pricing_product, notice: "Product was updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pricing_product.destroy!
    redirect_to pricing_products_path, notice: "Product was deleted successfully.", status: :see_other
  end

  private

  def set_pricing_product
    @pricing_product = PricingProduct.find(params[:id])
  end

  def pricing_product_params
    params.require(:pricing_product).permit(:sku, :product_desc, :prd_price, :prd_category)
  end
end
