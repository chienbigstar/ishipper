class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.string :name
      t.string :address_start
      t.float :latitude_start
      t.float :longitude_start
      t.string :address_finish
      t.float :latitude_finish
      t.float :longitude_finish
      t.string :delivery_time
      t.float :distance_invoice
      t.string :description
      t.float :price
      t.float :shipping_price
      t.integer :status, default: 0
      t.float :weight
      t.string :customer_name
      t.string :customer_number
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
