require "securerandom"

RNG_SEED = 42
rng = Random.new(RNG_SEED)
Faker::Config.random = Random.new(RNG_SEED)

EMPLOYEE_COUNT = Integer(ENV.fetch("SEED_EMPLOYEE_COUNT", 10_000))
AS_OF = Date.new(2026, 1, 1)
now = Time.current

FX_RATES = {
  "USD" => 1.0,
  "GBP" => 1.27,
  "EUR" => 1.08,
  "INR" => 0.012,
  "CAD" => 0.73,
  "AUD" => 0.66,
  "SGD" => 0.74,
  "BRL" => 0.18,
  "ZAR" => 0.055,
  "MXN" => 0.058
}.freeze

COUNTRIES = {
  "US" => { currency: "USD", market_factor: 1.00 },
  "GB" => { currency: "GBP", market_factor: 0.90 },
  "DE" => { currency: "EUR", market_factor: 0.85 },
  "FR" => { currency: "EUR", market_factor: 0.80 },
  "IN" => { currency: "INR", market_factor: 0.35 },
  "CA" => { currency: "CAD", market_factor: 0.85 },
  "AU" => { currency: "AUD", market_factor: 0.90 },
  "SG" => { currency: "SGD", market_factor: 0.85 },
  "BR" => { currency: "BRL", market_factor: 0.40 },
  "ZA" => { currency: "ZAR", market_factor: 0.40 }
}.freeze

LEVEL_BASELINE_USD = {
  junior: 70_000,
  mid: 100_000,
  senior: 140_000,
  staff: 180_000,
  principal: 230_000,
  manager: 200_000,
  director: 300_000
}.freeze

DEPARTMENTS = [
  "Engineering", "Sales", "Marketing", "Finance", "People",
  "Operations", "Product", "Customer Support", "Legal", "Design"
].freeze

GENDER_WEIGHTS = { female: 45, male: 45, non_binary: 3, undisclosed: 7 }.freeze
GENDER_PAY_FACTOR = { female: 0.96, male: 1.0, non_binary: 0.98, undisclosed: 0.99 }.freeze

def weighted_pick(weights, rng)
  total = weights.values.sum
  roll = rng.rand(total)
  cursor = 0
  weights.each do |key, weight|
    cursor += weight
    return key if roll < cursor
  end
  weights.keys.last
end

def local_cents_from_usd(usd_amount, currency)
  (usd_amount / FX_RATES.fetch(currency) * 100).round
end

puts "Resetting domain data..."
Salary.delete_all
Employee.delete_all
PayBand.delete_all
FxRate.delete_all

puts "Seeding FX rates..."
FxRate.insert_all(
  FX_RATES.map { |currency, rate| { currency: currency, rate_to_usd: rate, as_of: AS_OF, created_at: now, updated_at: now } }
)

puts "Seeding pay bands..."
band_rows = []
bands = {}
COUNTRIES.each do |country_code, config|
  LEVEL_BASELINE_USD.each do |level, baseline|
    mid_usd = baseline * config[:market_factor]
    mid = local_cents_from_usd(mid_usd, config[:currency])
    min = (mid * 0.80).round
    max = (mid * 1.20).round
    bands[[ level, country_code ]] = { currency: config[:currency], min: min, mid: mid, max: max }
    band_rows << {
      job_level: Employee.job_levels[level.to_s], country_code: country_code, currency: config[:currency],
      min_cents: min, mid_cents: mid, max_cents: max, created_at: now, updated_at: now
    }
  end
end
PayBand.insert_all(band_rows)

puts "Seeding HR manager user..."
hr_password = ENV.fetch("SEED_HR_PASSWORD") do
  raise "SEED_HR_PASSWORD must be set to seed in production" if Rails.env.production?

  "password123"
end
User.find_or_create_by!(email: "hr@acme.test") do |user|
  user.password = hr_password
  user.role = :hr_manager
end

puts "Seeding #{EMPLOYEE_COUNT} employees..."
country_codes = COUNTRIES.keys
levels = LEVEL_BASELINE_USD.keys
genders = Employee.genders
statuses = { active: 92, on_leave: 5, terminated: 3 }

employee_rows = Array.new(EMPLOYEE_COUNT) do |i|
  country_code = country_codes[rng.rand(country_codes.size)]
  level = levels[rng.rand(levels.size)]
  department = DEPARTMENTS[rng.rand(DEPARTMENTS.size)]
  gender = weighted_pick(GENDER_WEIGHTS, rng)
  status = weighted_pick(statuses, rng)
  hire_date = AS_OF - rng.rand(30..3650)

  {
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "employee#{i + 1}@acme.test",
    employee_number: format("ACME-%06d", i + 1),
    country_code: country_code,
    department: department,
    job_title: "#{level.to_s.titleize} #{department}",
    job_level: Employee.job_levels[level.to_s],
    gender: genders[gender.to_s],
    hire_date: hire_date,
    employment_status: Employee.employment_statuses[status.to_s],
    created_at: now,
    updated_at: now
  }
end

employee_rows.each_slice(2_000) { |slice| Employee.insert_all(slice) }

puts "Seeding salary history..."
salary_rows = []

Employee.select(:id, :country_code, :job_level, :gender, :hire_date).find_each(batch_size: 2_000) do |employee|
  level = employee.job_level.to_sym
  band = bands.fetch([ level, employee.country_code ])
  gender_factor = GENDER_PAY_FACTOR.fetch(employee.gender&.to_sym, 1.0)

  spread = rng.rand(0.82..1.20)
  spread = rng.rand < 0.05 ? spread * rng.rand(0.70..1.35) : spread
  current_amount = (band[:mid] * spread * gender_factor).round

  raises = rng.rand(1..3)
  amounts = Array.new(raises) { |step| (current_amount * (1 - (0.06 * (raises - 1 - step)))).round }
  first_year = [ employee.hire_date.year, AS_OF.year - raises ].min

  amounts.each_with_index do |amount, index|
    salary_rows << {
      employee_id: employee.id,
      amount_cents: [ amount, 1 ].max,
      currency: band[:currency],
      effective_date: Date.new(first_year + index, 1, 1),
      current: index == amounts.size - 1,
      created_at: now,
      updated_at: now
    }
  end

  if salary_rows.size >= 5_000
    Salary.insert_all(salary_rows)
    salary_rows = []
  end
end
Salary.insert_all(salary_rows) if salary_rows.any?

puts "Done. Employees: #{Employee.count}, Salaries: #{Salary.count}, Current: #{Salary.current.count}"
