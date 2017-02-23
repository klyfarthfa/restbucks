class OrdersController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  before_action :authenticate
  before_action :set_order, only: [:show, :update, :destroy, :pay, :complete]


  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    if @order.save
      render :show, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    if @order.update_order(order_params)
      render :show, status: :ok
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    if @order.cancel
      render :show, status: :ok
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment/1
  # PATCH/PUT /payment/1.json
  def pay
    if @order.pay
      @order.prepare #cheating for now
      render :show, status: :ok
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /receipt/1
  # DELETE /receipt/1.json
  def complete
    if @order.complete
      render :show, status: :ok
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {}).permit(:location, {items: [:id, :name, :quantity, :size]}).tap do |order_params|
        if params[:order] && params[:order][:items]
          params[:order][:items].each_with_index { |item, index| 
            item_options = item.reject { |k,v| ["id","quantity", "size", "name"].include?(k) }
            item_options.permit!
            order_params[:items][index][:options] = item_options unless item_options.empty?
          }
          order_params[:order_items_attributes] = order_params.delete :items if order_params[:items]
        end
      end
    end

    def authenticate
      authenticate_with_http_basic do |user, password|
        unless user == "happy" && password == "golucky"
          head :forbidden and return
        end
      end
    end
end
