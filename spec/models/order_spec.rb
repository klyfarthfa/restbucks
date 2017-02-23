require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order_item1) {
    {
      quantity: 1,
      size: 'small',
      name: 'latte',
      options: { 'milk' => 'whole'}
    }
  }
  describe "creating a new order" do
    subject { Order.new(params) }
    context "everything is valid" do
      let(:params) {
        {
          location: "takeAway",
          order_items_attributes: [
            order_item1
          ]
        }
      }
      it "should not explode" do
        expect(subject).to be_truthy
      end
      it 'should be savable' do
        expect { subject.save }.to change { Order.count }.by(1)
        expect(subject.id).to be_present
      end
    end

    shared_examples 'an invalid order' do
      it { is_expected.to_not be_valid }
      it 'should not be savable' do
        expect { subject.save }.to_not change { Order.count}
        expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
        expect(subject).to be_a_new(Order)
      end
    end

    shared_examples 'a required presence' do |parameter|
      context 'is blank' do
        before(:each) do
          { parameter => '' }
          params.merge!({ parameter => '' })
        end
        it_should_behave_like 'an invalid order'
      end
      context 'is not present' do
        it_should_behave_like 'an invalid order'
      end
    end

    context "location" do
      let(:params) {
        {
          order_items_attributes: [
            order_item1
          ]
        }
      }
      it_should_behave_like 'a required presence', :location
    end
    
    context "state" do
      let(:params) {
        {
          location: "takeAway",
          order_items_attributes: [
            order_item1
          ]
        }
      }
      it 'should be auto-assigned on a new object' do
        subject.save
        expect(subject.state).to be_present
        expect(subject.state).to eq("pending")
      end
    end

    context "order_items_attributes" do
      let(:params) {
        {
          location: "takeAway"
        }
      }
      context "is empty" do
        before(:each) do
          params.merge!({order_items_attributes: [] })
        end
        it_should_behave_like 'an invalid order'
      end
    end
  end

  describe "order state allowances" do
    let(:params) {
      {
        location: "takeAway",
        order_items_attributes: [
          order_item1
        ]
      }
    }
    let (:order) {
      Order.create! params
    }

    before(:each) do
      order.update_attribute(:state, begin_state)
    end

    TRANSITION_STATE_MAP = {
      :cancel => "cancelled",
      :pay => "paid",
      :prepare => "prepared",
      :complete => "completed"
    }

    ALLOWED_METHODS = {
      "pending" => [:cancel, :pay],
      "cancelled" => [],
      "paid" => [:prepare],
      "prepared" => [:complete],
      "completed" => []
    }

    shared_examples 'an allowed action' do |state|
      it 'should be allowed' do
        expect(subject).to be_truthy
        expect(order.state).to eq(state)
      end
    end

    shared_examples 'not allowed action' do |state|
      it 'should not transition state' do
        expect { subject }.to_not change(order, :state)
        expect(order.state).to_not eq(state)
      end
    end

    shared_examples 'a state governed by the transition map' do |begin_state|
      TRANSITION_STATE_MAP.each do |method, state|
        next if state == begin_state
        context "method #{method} transition to state #{state}" do
          subject { order.send(method) }
          if ALLOWED_METHODS[begin_state].include?(method)
            it_should_behave_like 'an allowed action', state
          else
            it_should_behave_like 'not allowed action', state
          end
        end
      end
    end

    Order::VALID_STATES.each do |bs|
      context "in #{bs} state" do
        let(:begin_state) { bs }
        it_should_behave_like 'a state governed by the transition map', bs
        
        context 'updating the order' do
          let(:new_params) {
            {
              location: "furtherAway",
              order_items_attributes: [
                order_item1,
                order_item1
              ]
            }
          }
          subject { order.update_order(new_params) }
          before(:each) do
            order.update_attribute(:location, "takeAway")
          end
          if bs == 'pending'
            it 'should change the order appropriately' do
              expect { subject }.to_not change { Order.count}
              expect(order.state).to eq("pending")
              expect(order.order_items.count).to eq(3)
              expect(order.location).to eq("furtherAway")
            end
          else
            it 'should not be allowed' do
              expect { subject }.not_to change(order, :location)
              expect(order.location).to eq("takeAway")
            end
          end
        end
      end
    end
  end
end
