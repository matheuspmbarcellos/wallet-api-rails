class Wallet < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy

  validates :limit_max, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_limit, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :limit_max }
  validates :credit_available, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default_values
  before_update :set_custom_limit
 
  
  def add_limit(value)
    self.update(:limit_max => self.limit_max + value)
  end
  
	def remove_limit(value)
		self.update(:limit_max => self.limit_max - value)
	end
  
  def credit_available
    total_spent = self.cards.sum(:current_spent_amount)
    self.credit_available = self.custom_limit - total_spent
    return credit_available
  end

  def make_purchase(amount)
    if amount > self.credit_available
      errors.add(:limit_max, "No credit/card available for this purchase!")
      return false
    else
      remaining_value = amount
      eligible_cards = self.cards.where('spent < limit')
      
      eligible_cards.each do |card|
        available_credit = card.limit - card.current_spent_amount
        purchase_amount = [remaining_value, available_credit].min

        if card.spend(purchase_amount)
          remaining_value -= purchase_amount
        else
          errors.add(:limit, "Something went wrong (internal error).")
          return false
        end

        break if remaining_value.zero?
      end

      remaining_value.zero?
    end
  end
  

  private 

		def set_default_values
			self.limit_max ||= 0
      self.custom_limit ||= self.limit_max
		end

		def set_custom_limit
			self.custom_limit = [self.custom_limit, 0].max
      self.custom_limit = [self.custom_limit, self.limit_max].min
		end

end
