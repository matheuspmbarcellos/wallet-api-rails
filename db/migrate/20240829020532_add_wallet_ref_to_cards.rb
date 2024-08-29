class AddWalletRefToCards < ActiveRecord::Migration[7.1]
  def change
    add_reference :cards, :wallet, null: false, foreign_key: true
  end
end
