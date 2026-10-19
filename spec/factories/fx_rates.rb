FactoryBot.define do
  factory :fx_rate do
    currency { "USD" }
    rate_to_usd { 1.0 }
    as_of { Date.current }
  end
end
