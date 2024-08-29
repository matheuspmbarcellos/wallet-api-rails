class User < ApplicationRecord
  has_one :wallet, dependent: :destroy
end