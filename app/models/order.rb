class Order < ApplicationRecord
  VALID_STATES = ['pending', 'cancelled', 'paid', 'prepared', 'completed']
  has_many :order_items, inverse_of: :order, dependent: :destroy
  accepts_nested_attributes_for :order_items
  validates :location, presence: true
  validates :order_items, presence: true
  validates :state, inclusion: { in: VALID_STATES, allow_blank: true }


  

  before_create do
    self.state ||= 'pending'
  end

  #State Transitions
  # -> CREATE /order -> pending
  # pending -> UPDATE /order -> pending
  # pending -> DELETE /order -> cancelled
  # pending -> UPDATE /payment -> paid
  # paid -> ??? -> prepared
  # prepared -> DELETE /receipt -> completed
  def update_order(params)
    if self.state != 'pending'
      errors.add(:base, "can only modify order if in pending state")
      return false 
    end
    params.delete(:state) #ensure that this somehow doesn't try to change state
    update(params)
  end

  def cancel
    if self.state != 'pending'
      errors.add(:base, "can only cancel order if in pending state")
      return false
    end
    update(state: 'cancelled')
  end

  def pay
    if self.state != 'pending'
      errors.add(:base, "can only pay for order if in pending state")
      return false
    end
    update(state: 'paid')
  end

  def prepare
    if self.state != 'paid'
      errors.add(:base, "can only prepare order if in paid state")
      return false
    end
    update(state: 'prepared')
  end

  def complete
    if self.state != 'prepared'
      errors.add(:base, "can only complete order if in prepared state")
      return false
    end
    update(state: 'completed')
  end
end
