class User < ApplicationRecord
  has_one :wallet, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :cpf, presence: true, uniqueness: true
end