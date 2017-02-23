class CreateOrderItems < ActiveRecord::Migration[5.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true
      t.string :size
      t.string :name
      t.integer :quantity
      t.blob :options

      t.timestamps
    end
  end
end
