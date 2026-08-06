class PricingProduct < ApplicationRecord
  validates :sku, presence: true, uniqueness: true
  validates :product_desc, :prd_category, presence: true
  validates :prd_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
