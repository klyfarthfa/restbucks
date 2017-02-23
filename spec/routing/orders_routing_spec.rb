require "rails_helper"

RSpec.describe OrdersController, type: :routing do
  describe "routing" do

    it "routes to #show" do
      expect(:get => "/order/1").to route_to("orders#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/order").to route_to("orders#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/order/1").to route_to("orders#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/order/1").to route_to("orders#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/order/1").to route_to("orders#destroy", :id => "1")
    end

    it "routes to #pay via PUT" do
      expect(:put => "/payment/1").to route_to("orders#pay", :id => "1")
    end
    it "routes to #pay via PATCH" do
      expect(:patch => "/payment/1").to route_to("orders#pay", :id => "1")
    end
    it "routes to #complete" do
      expect(:delete => "/receipt/1").to route_to("orders#complete", :id => "1")
    end
  end
end
