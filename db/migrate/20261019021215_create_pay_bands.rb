class CreatePayBands < ActiveRecord::Migration[8.1]
  def change
    create_table :pay_bands do |t|
      t.integer :job_level, null: false
      t.string :country_code, null: false, limit: 2
      t.string :currency, null: false, limit: 3
      t.bigint :min_cents, null: false
      t.bigint :mid_cents, null: false
      t.bigint :max_cents, null: false

      t.timestamps
    end

    add_index :pay_bands, [ :job_level, :country_code ], unique: true
  end
end
