# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_19_021216) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "employee_number", null: false
    t.string "country_code", limit: 2, null: false
    t.string "department", null: false
    t.string "job_title", null: false
    t.integer "job_level", null: false
    t.integer "gender"
    t.date "hire_date", null: false
    t.integer "employment_status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_employees_on_country_code"
    t.index ["department"], name: "index_employees_on_department"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_number"], name: "index_employees_on_employee_number", unique: true
    t.index ["employment_status"], name: "index_employees_on_employment_status"
    t.index ["job_level"], name: "index_employees_on_job_level"
  end

  create_table "fx_rates", force: :cascade do |t|
    t.string "currency", limit: 3, null: false
    t.decimal "rate_to_usd", precision: 18, scale: 8, null: false
    t.date "as_of", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency"], name: "index_fx_rates_on_currency", unique: true
  end

  create_table "pay_bands", force: :cascade do |t|
    t.integer "job_level", null: false
    t.string "country_code", limit: 2, null: false
    t.string "currency", limit: 3, null: false
    t.bigint "min_cents", null: false
    t.bigint "mid_cents", null: false
    t.bigint "max_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_level", "country_code"], name: "index_pay_bands_on_job_level_and_country_code", unique: true
  end

  create_table "salaries", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "amount_cents", null: false
    t.string "currency", limit: 3, null: false
    t.date "effective_date", null: false
    t.boolean "current", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "effective_date"], name: "index_salaries_on_employee_id_and_effective_date"
    t.index ["employee_id"], name: "index_salaries_on_employee_id"
    t.index ["employee_id"], name: "index_salaries_on_employee_id_current", unique: true, where: "current"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "salaries", "employees"
  add_foreign_key "sessions", "users"
end
