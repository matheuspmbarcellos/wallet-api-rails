class RemoveCreditAvailableFromWallets < ActiveRecord::Migration[7.1]
  def change
    remove_column :wallets, :credit_available, :decimal
  end
end
