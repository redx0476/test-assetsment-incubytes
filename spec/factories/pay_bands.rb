FactoryBot.define do
  factory :pay_band do
    job_level { :mid }
    country_code { "US" }
    currency { "USD" }
    min_cents { 8_000_000 }
    mid_cents { 10_000_000 }
    max_cents { 12_000_000 }
  end
end
