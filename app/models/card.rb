class Card < ApplicationRecord
  belongs_to :wallet

  validates :number, presence: true, uniqueness: true
  validates :name_printed, presence: true
  validates :due_date, presence: true
  validates :expiration_month, presence: true, inclusion: { in: 1..12 }
  validates :expiration_year, presence: true, numericality: { greater_than_or_equal_to: Date.today.year }
  validates :limit, numericality: { greater_than_or_equal_to: 0 }
end
