FactoryBot.define do
  factory :employee do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "employee#{n}@acme.test" }
    sequence(:employee_number) { |n| format("ACME-%05d", n) }
    country_code { "US" }
    department { "Engineering" }
    job_title { "Software Engineer" }
    job_level { :mid }
    gender { :undisclosed }
    hire_date { 2.years.ago.to_date }
    employment_status { :active }

    trait :with_salary do
      transient do
        amount_cents { 10_000_000 }
        currency { "USD" }
      end

      after(:create) do |employee, evaluator|
        Salary.record_for(
          employee,
          amount_cents: evaluator.amount_cents,
          currency: evaluator.currency,
          effective_date: employee.hire_date
        )
      end
    end
  end
end
