require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let(:headers) {
    {
      "ACCEPT" => "application/json",
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("happy", "golucky")
    }
  }
  let(:createable_attributes) {
    {location: "takeAway", order_items_attributes: [ {quantity: 1, size: 'small', name: 'latte', options: {milk: 'whole'}}]}
  }
  describe "GET /order/:id" do
    context 'with an existing order id' do
      let(:order) {
        Order.create! createable_attributes
      }
      it 'should render json appropriate for the order' do
        get "/order/#{order.id}", headers: headers
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["id"]).to eq(order.id)
        expect(json["location"]).to eq("takeAway")
        expect(json["items"].count).to eq(1)
        expect(json["items"][0]).to eq({"id" => order.order_items.first.id, "quantity" => 1, "size" => 'small', "name" => 'latte', 'milk' => 'whole'})
      end
    end
    context 'with a non-existant order id' do
      it 'should render not found' do
        Order.destroy_all
        expect { get "/order/1", headers: headers }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'PUT/PATCH /order/:id' do
    let(:order) {
      Order.create! createable_attributes
    }
    context 'with appropriate content' do
      let(:new_params) {
        {
          "location": "theInnerRoom"
        }
      }
      context 'order is in pending' do 
        before(:each) do
          order.update_attribute(:state, 'pending')
        end
        it 'should properly update and show the order' do
          put "/order/#{order.id}", headers: headers, params: { order: new_params }
          json = response.parsed_body
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:ok)
          expect(json["id"]).to eq(order.id)
          expect(json["location"]).to eq("theInnerRoom")
          expect(json["items"].count).to eq(1)
          expect(json["status"]).to eq("pending")
          order.reload
          expect(order.location).to eq("theInnerRoom")
        end
      end
      context 'order is not in pending' do
        before(:each) do
          order.update_attribute(:state, 'cancelled')
        end
        it 'should render an error' do
          put "/order/#{order.id}", headers: headers, params: { order: new_params }
          json = response.parsed_body
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json["base"]).to eq(["can only modify order if in pending state"])
        end
      end
    end
  end

  describe 'POST /order' do
    context 'with appropriate content' do
      let(:content) {
        {location: "takeAway", items: [ {quantity: 1, size: 'small', name: 'latte', milk: 'whole'}]}
      }
      it 'should create a new order and return appropriate json content' do
        post "/order", headers: headers, params: { order: content }
        json = response.parsed_body
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:created)
        expect(response.headers["Location"]).to be_present
        expect(json["id"]).to be_present
        expect(json["location"]).to eq("takeAway")
        expect(json["items"].count).to eq(1)
      end
    end
    context 'with broken/missing content' do
      let(:content) {
        {items: [ {quantity: 1, size: 'small', name: 'latte', milk: 'whole'}]}
      }
      it 'should render an error' do
        post "/order", headers: headers, params: { order: content }
        json = response.parsed_body
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["location"]).to eq(["can't be blank"])
      end
    end
  end

  describe 'DELETE /order/:id' do
    context 'with an existing id' do
      let(:order) {
        Order.create! createable_attributes
      }
      context 'order is in pending' do
        before(:each) do
          order.update_attribute(:state, 'pending')
        end
        it 'should cancel the order' do
          delete "/order/#{order.id}", headers: headers
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json["status"]).to eq("cancelled")
        end
      end
      context 'order is not in pending' do
        before(:each) do
          order.update_attribute(:state, 'paid')
        end
        it 'should render an error' do
          delete "/order/#{order.id}", headers: headers
          json = response.parsed_body
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json["base"]).to eq(["can only cancel order if in pending state"])
        end
      end
    end
    context 'not existing id' do
      it 'should render not found' do
        Order.destroy_all
        expect { delete "/order/1", headers: headers}.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'PUT /payment/:id' do
    context 'with an existing id' do
      let(:order) {
        Order.create! createable_attributes
      }
      context 'order is in pending' do
        before(:each) do
          order.update_attribute(:state, 'pending')
        end
        it 'should cancel the order' do
          put "/payment/#{order.id}", headers: headers
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          # expect(json["status"]).to eq("paid")
          expect(json["status"]).to eq("prepared") #because we are cheating
        end
      end
      context 'order is not in pending' do
        before(:each) do
          order.update_attribute(:state, 'paid')
        end
        it 'should render an error' do
          put "/payment/#{order.id}", headers: headers
          json = response.parsed_body
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json["base"]).to eq(["can only pay for order if in pending state"])
        end
      end
    end
    context 'not existing id' do
      it 'should render not found' do
        Order.destroy_all
        expect { put "/payment/1", headers: headers }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'DELETE /receipt/:id' do
    context 'with an existing id' do
      let(:order) {
        Order.create! createable_attributes
      }
      context 'order is prepared' do
        before(:each) do
          order.update_attribute(:state, 'prepared')
        end
        it 'should cancel the order' do
          delete "/receipt/#{order.id}", headers: headers
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json["status"]).to eq("completed")
        end
      end
      context 'order is not prepared' do
        before(:each) do
          order.update_attribute(:state, 'cancelled')
        end
        it 'should render an error' do
          delete "/receipt/#{order.id}", headers: headers
          json = response.parsed_body
          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json["base"]).to eq(["can only complete order if in prepared state"])
        end
      end
    end
    context 'not existing id' do
      it 'should render not found' do
        Order.destroy_all
        expect { delete "/receipt/1", headers: headers }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
