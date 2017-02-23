require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  
  let!(:order) { Order.create!({location: 'takeaway', order_items_attributes: [{quantity: 1, size: 'large', name: 'coffee'}]})}
  
  describe "creating a new order item" do
    subject { OrderItem.new(params) }
    context 'everything is valid' do
      let(:params) {
        {
          order: order,
          quantity: 1,
          size: 'small',
          name: 'latte',
          options: { 'milk' => 'whole'}
        }
      }
      it "should not explode" do
        expect(subject).to be_truthy
      end
      it 'should be savable' do
        expect { subject.save }.to change { OrderItem.count }.by(1)
        expect(subject.id).to be_present
      end
    end
  
  
    shared_examples 'an invalid order item' do
      it { is_expected.to_not be_valid }
      it 'should not be savable' do
        expect { subject.save }.to_not change { OrderItem.count}
        expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
        expect(subject).to be_a_new(OrderItem)
      end
    end

    shared_examples 'a required presence' do |parameter|
      context 'is blank' do
        before(:each) do
          { parameter => '' }
          params.merge!({ parameter => '' })
        end
        it_should_behave_like 'an invalid order item'
      end
      context 'is not present' do
        it_should_behave_like 'an invalid order item'
      end
    end
    
    shared_examples 'a positive numerical field' do |parameter|
      context 'is not a number' do
        before(:each) do
          params.merge!({ parameter => 'a black cat' })
        end
        it_should_behave_like 'an invalid order item'
      end
      context 'is less than zero' do
        before(:each) do
          params.merge!({ parameter => -5046 })
        end
        it_should_behave_like 'an invalid order item'
      end
      context 'is zero' do
        before(:each) do
          params.merge!({ parameter => 0 })
        end
        it_should_behave_like 'an invalid order item'
      end
    end

    context "quantity" do
      let(:params) {
        {
          order: order,
          size: 'small',
          name: 'latte',
          options: { 'milk' => 'whole'}
        }
      }
      it_should_behave_like 'a required presence', :quantity
      it_should_behave_like 'a positive numerical field', :quantity
    end

    context "name" do
      let(:params) {
        {
          order: order,
          size: 'small',
          quantity: 1,
          options: { 'milk' => 'whole'}
        }
      }
      it_should_behave_like 'a required presence', :name
    end

    context "size" do
      let(:params) {
        {
          order: order,
          name: 'latte',
          quantity: 1,
          options: { 'milk' => 'whole'}
        }
      }
      it_should_behave_like 'a required presence', :size
    end
  end
end
