class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.decimal :limit_max
      t.decimal :custom_limit
      t.decimal :credit_available

      t.timestamps
    end
  end
end
