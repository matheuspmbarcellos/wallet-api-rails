class RenameLimitInCards < ActiveRecord::Migration[7.1]
  def change
    rename_column :cards, :limit, :card_limit
  end
end
