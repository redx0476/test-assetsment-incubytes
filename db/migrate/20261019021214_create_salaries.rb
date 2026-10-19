class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.bigint :amount_cents, null: false
      t.string :currency, null: false, limit: 3
      t.date :effective_date, null: false
      t.boolean :current, null: false, default: false

      t.timestamps
    end

    add_index :salaries, [ :employee_id, :effective_date ]
    add_index :salaries, :employee_id, unique: true, where: "current", name: "index_salaries_on_employee_id_current"
  end
end
