json.extract! order_item, :id, :name, :size, :quantity
order_item.options.each do |key, value|
  json.set! key, value
end