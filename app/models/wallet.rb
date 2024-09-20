class Wallet < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy

  validates :limit_max, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_limit, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :limit_max }


  before_validation :set_default_values
  before_update :set_custom_limit

  def update_custom_limit(limit)
    self.update(custom_limit: limit)
  end 
  
  def add_limit(value)
    if self.custom_limit == self.limit_max
      self.update(limit_max: self.limit_max + value, custom_limit: self.custom_limit + value)
    else
      self.update(limit_max: self.limit_max + value)
    end
  end
  
	def remove_limit(value)
    new_limit_max = self.limit_max - value

    if self.custom_limit > new_limit_max
      self.update(limit_max: new_limit_max, custom_limit: new_limit_max)
    else
      self.update(limit_max: new_limit_max)
    end
	end
  
  def credit_available
    total_spent = self.cards.sum(:current_spent_amount)
    self.custom_limit - total_spent
  end

  def make_purchase(amount)
    if amount > self.credit_available
      errors.add(:limit_max, "No credit/card available for this purchase!")
      return false
    else
      remaining_value = amount
      
      eligible_cards = self.cards.where('current_spent_amount < card_limit')
                                 .sort_by do |card|
                                    next_due_date = if card.due_date < Date.today.day
                                                      Date.today.next_month.change(day: card.due_date)
                                                    else
                                                      Date.today.change(day: card.due_date)
                                                    end
                                    [next_due_date, -card.card_limit]
                                  end
          eligible_cards.reverse.each do |card|
          available_credit = card.card_limit - card.current_spent_amount
          purchase_amount = [remaining_value, available_credit].min

        if card.spend(purchase_amount)
          remaining_value -= purchase_amount
        else
          errors.add(:card_limit, "Something went wrong (internal error).")
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
