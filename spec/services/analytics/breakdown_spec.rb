require "rails_helper"

RSpec.describe Analytics::Breakdown do
  before do
    create(:fx_rate, currency: "USD", rate_to_usd: 1.0)
    create(:employee, :with_salary, amount_cents: 10_000_000, currency: "USD", country_code: "US", department: "Engineering")
    create(:employee, :with_salary, amount_cents: 20_000_000, currency: "USD", country_code: "US", department: "Sales")
    create(:employee, :with_salary, amount_cents: 6_000_000, currency: "USD", country_code: "GB", department: "Sales")
  end

  it "groups by country with per-group aggregates, ordered by total desc" do
    result = described_class.new("country").call

    expect(result[:dimension]).to eq("country")
    us = result[:groups].find { |g| g[:key] == "US" }
    expect(us[:headcount]).to eq(2)
    expect(us[:total_usd_cents]).to eq(30_000_000)
    expect(us[:median_usd_cents]).to eq(15_000_000)
    expect(result[:groups].map { |g| g[:key] }).to eq(%w[US GB])
  end

  it "falls back to country for an unknown dimension" do
    expect(described_class.new("bogus").call[:dimension]).to eq("country")
  end
end
