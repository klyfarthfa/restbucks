Rails.application.routes.draw do
  resources :order, except: [:index], controller: "orders"
  resources :payment, only: [:update], controller: "orders", action: "pay"
  resources :receipt, only: [:destroy], controller: "orders", action: "complete"
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
