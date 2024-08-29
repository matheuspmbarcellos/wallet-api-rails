class AddUserRefToWallets < ActiveRecord::Migration[7.1]
  def change
    add_reference :wallets, :user, null: false, foreign_key: true
  end
end
