require "rails_helper"

RSpec.describe FxConverter do
  subject(:converter) { described_class.new(rates: { "USD" => 1.0, "EUR" => 1.1 }) }

  it "converts local minor units to USD cents" do
    expect(converter.to_usd_cents(10_000, "USD")).to eq(10_000)
    expect(converter.to_usd_cents(10_000, "EUR")).to eq(11_000)
  end

  it "is case-insensitive on currency" do
    expect(converter.to_usd_cents(10_000, "eur")).to eq(11_000)
  end

  it "raises for an unknown currency" do
    expect { converter.to_usd_cents(10_000, "JPY") }.to raise_error(FxConverter::UnknownCurrencyError)
  end

  it "loads rates from the database when none are injected" do
    create(:fx_rate, currency: "GBP", rate_to_usd: 1.25)
    expect(described_class.new.to_usd_cents(10_000, "GBP")).to eq(12_500)
  end
end
