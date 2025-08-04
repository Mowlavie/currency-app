class CreateExchangeRates < ActiveRecord::Migration[8.0]
  def change
    create_table :exchange_rates do |t|
      t.string :base_currency, null: false, limit: 3
      t.string :target_currency, null: false, limit: 3
      t.decimal :rate, precision: 10, scale: 6, null: false
      t.datetime :fetched_at, null: false

      t.timestamps
    end

    add_index :exchange_rates, [:base_currency, :target_currency], unique: true
    add_index :exchange_rates, :fetched_at
  end
end