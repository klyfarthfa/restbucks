json.extract! order, :id, :location, :created_at, :updated_at
json.set! :status, order.state
json.set! :items do
  json.array! order.order_items, partial: 'orders/order_item', as: :order_item
end
json.url order_url(order, format: :json)
