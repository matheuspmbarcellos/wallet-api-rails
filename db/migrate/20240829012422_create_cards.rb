class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :number
      t.string :name_printed
      t.string :expiration_month
      t.string :expiration_year
      t.string :cvv
      t.string :due_date
      t.decimal :limit
      t.decimal :current_spent_amount

      t.timestamps
    end
  end
end
