require "rails_helper"

RSpec.describe Analytics::Payroll do
  before do
    create(:fx_rate, currency: "USD", rate_to_usd: 1.0)
    create(:fx_rate, currency: "EUR", rate_to_usd: 2.0)

    create(:employee, :with_salary, amount_cents: 10_000_000, currency: "USD")
    create(:employee, :with_salary, amount_cents: 5_000_000, currency: "EUR")
    create(:employee, :with_salary, amount_cents: 30_000_000, currency: "USD")
    create(:employee, :with_salary, amount_cents: 99_000_000, currency: "USD", employment_status: :terminated)
  end

  it "normalizes to USD and computes KPIs over active employees only" do
    result = described_class.new.call

    expect(result[:headcount]).to eq(3)
    expect(result[:total_usd_cents]).to eq(50_000_000)
    expect(result[:median_usd_cents]).to eq(10_000_000)
    expect(result[:average_usd_cents]).to eq(16_666_666)
  end

  it "bucketizes the distribution by USD compensation" do
    distribution = described_class.new.call[:distribution]
    counts = distribution.to_h { |row| [ row[:bucket], row[:headcount] ] }

    expect(counts["$100k–$150k"]).to eq(2)
    expect(counts["$200k+"]).to eq(1)
  end
end
