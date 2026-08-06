class CreatePricingProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :pricing_products do |t|
      t.string :sku, null: false
      t.text :product_desc, null: false
      t.decimal :prd_price, precision: 10, scale: 2, null: false
      t.string :prd_category, null: false

      t.timestamps
    end

    add_index :pricing_products, :sku, unique: true
  end
end
