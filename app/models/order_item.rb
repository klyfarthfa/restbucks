class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  validates :quantity, :size, :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  
  serialize :options, Hash
end
