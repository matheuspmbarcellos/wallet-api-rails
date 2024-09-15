class Card < ApplicationRecord
  belongs_to :wallet

  validates :number, presence: true, uniqueness: true
  validates :name_printed, presence: true
  validates :due_date, presence: true, inclusion: { in: 1..30 }
  validates :expiration_month, presence: true, inclusion: { in: 1..12 }
  validates :expiration_year, presence: true, numericality: { greater_than_or_equal_to: Date.today.year }
  validates :limit, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default_values
  after_create :add_wallet_limit
  after_destroy :remove_wallet_limit

  def spend(purchase_amount)
    available_credit = self.limit - self.current_spent_amount

    if purchase_amount <= available_credit
      self.current_spent_amount += purchase_amount
      self.save
      return true
    else
      return false
    end
  end

  def pay(amount)    
    if amount <= 0
      erros.add(:base, "Payment amount must be greater than zero")
      return false
    end    

    if amount > self.current_spent_amount
      errors.add(:base, "Payment amount exceeds the amount spent")
      return false
    end
    
    self.current_spent_amount -= amount
    self.save
  end

  
  private 

  def set_default_values
    self.current_spent_amount ||= 0
  end

  def add_wallet_limit
    self.wallet.add_limit(self.limit)
  end

  def remove_wallet_limit
    self.wallet.remove_limit(self.limit)
  end
  

end
