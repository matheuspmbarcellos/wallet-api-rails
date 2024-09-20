class ChangeDueDateAndExpirationFieldsToInteger < ActiveRecord::Migration[7.1]
  def change
    change_column :cards, :due_date, 'integer USING CAST(due_date AS integer)'
    change_column :cards, :expiration_month, 'integer USING CAST(expiration_month AS integer)'
    change_column :cards, :expiration_year, 'integer USING CAST(expiration_year AS integer)'
  end
end
