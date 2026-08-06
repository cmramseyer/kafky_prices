require "securerandom"

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

    if save_product_with_created_event
      redirect_to @pricing_product, notice: "Product was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @pricing_product.assign_attributes(pricing_product_params)

    if save_product_with_price_updated_event
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

  def save_product_with_created_event
    saved = false

    PricingProduct.transaction do
      saved = @pricing_product.save
      create_product_created_event if saved
    end

    saved
  end

  def save_product_with_price_updated_event
    price_changed = @pricing_product.will_save_change_to_prd_price?
    saved = false

    PricingProduct.transaction do
      saved = @pricing_product.save
      create_product_price_updated_event if saved && price_changed
    end

    saved
  end

  def create_product_created_event
    event_id = SecureRandom.uuid
    create_outbox_event(event_id, "product.created", product_created_payload(event_id))
  end

  def create_product_price_updated_event
    event_id = SecureRandom.uuid
    create_outbox_event(event_id, "product.price_updated", product_price_updated_payload(event_id))
  end

  def create_outbox_event(event_id, event_type, payload)
    OutboxEvent.create!(
      event_id: event_id,
      event_type: event_type,
      aggregate_type: "PricingProduct",
      aggregate_id: @pricing_product.id,
      payload: payload
    )
  end

  def product_created_payload(event_id)
    event_payload(event_id, "product.created").merge(
      data: {
        sku: @pricing_product.sku,
        product_desc: @pricing_product.product_desc,
        prd_price: formatted_price,
        prd_category: @pricing_product.prd_category
      }
    )
  end

  def product_price_updated_payload(event_id)
    event_payload(event_id, "product.price_updated").merge(
      data: {
        sku: @pricing_product.sku,
        prd_price: formatted_price
      }
    )
  end

  def event_payload(event_id, event_type)
    {
      event_id: event_id,
      event_type: event_type,
      event_version: 1,
      source: "kafky_prices",
      occurred_at: Time.current.iso8601
    }
  end

  def formatted_price
    format("%.2f", @pricing_product.prd_price)
  end
end
