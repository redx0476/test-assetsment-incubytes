FactoryBot.define do
  factory :salary do
    employee
    amount_cents { 10_000_000 }
    currency { "USD" }
    effective_date { 1.year.ago.to_date }
    current { true }
  end
end
