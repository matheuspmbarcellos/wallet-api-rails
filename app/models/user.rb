class User < ApplicationRecord
  has_one :wallet, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :cpf, presence: true, uniqueness: true

  after_create :create_wallet

  private

  def create_wallet
    self.create_wallet!
  end
  
end