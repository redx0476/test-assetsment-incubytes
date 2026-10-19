class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :employee_number, null: false
      t.string :country_code, null: false, limit: 2
      t.string :department, null: false
      t.string :job_title, null: false
      t.integer :job_level, null: false
      t.integer :gender
      t.date :hire_date, null: false
      t.integer :employment_status, null: false, default: 0

      t.timestamps
    end

    add_index :employees, :email, unique: true
    add_index :employees, :employee_number, unique: true
    add_index :employees, :country_code
    add_index :employees, :department
    add_index :employees, :job_level
    add_index :employees, :employment_status
  end
end
