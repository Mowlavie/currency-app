class CreateConversions < ActiveRecord::Migration[8.0]
  def change
    create_table :conversions do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :converted_amount, precision: 10, scale: 2, null: false
      t.string :base_currency, null: false, limit: 3
      t.string :target_currency, null: false, limit: 3
      t.references :exchange_rate, null: false, foreign_key: true

      t.timestamps
    end

    add_index :conversions, :created_at
  end
end