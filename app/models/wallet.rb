class Wallet < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy

  validates :limit_max, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_limit, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :limit_max }
  validates :credit_available, numericality: { greater_than_or_equal_to: 0 }
end
