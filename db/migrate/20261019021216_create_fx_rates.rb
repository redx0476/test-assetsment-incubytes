class CreateFxRates < ActiveRecord::Migration[8.1]
  def change
    create_table :fx_rates do |t|
      t.string :currency, null: false, limit: 3
      t.decimal :rate_to_usd, null: false, precision: 18, scale: 8
      t.date :as_of, null: false

      t.timestamps
    end

    add_index :fx_rates, :currency, unique: true
  end
end
