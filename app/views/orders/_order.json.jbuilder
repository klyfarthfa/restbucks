json.extract! order, :id, :location, :created_at, :updated_at
json.set! :status, order.state
json.set! :items do
  json.array! order.order_items, partial: 'orders/order_item', as: :order_item
end
json.set! :links do
  json.set! :self, order_url(order, format: :json)
  json.set! :payment, payment_url(order, format: :json) if order.state == 'pending'
  json.set! :receipt, receipt_url(order, format: :json) if order.state == 'prepared'
end
