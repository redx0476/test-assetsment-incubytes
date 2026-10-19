require "rails_helper"

RSpec.describe Analytics::Equity do
  before do
    create(:fx_rate, currency: "USD", rate_to_usd: 1.0)

    create(:employee, :with_salary, amount_cents: 10_000_000, currency: "USD", gender: :male, department: "Engineering")
    create(:employee, :with_salary, amount_cents: 10_000_000, currency: "USD", gender: :male, department: "Engineering")
    create(:employee, :with_salary, amount_cents: 9_000_000, currency: "USD", gender: :female, department: "Engineering")
    create(:employee, :with_salary, amount_cents: 9_000_000, currency: "USD", gender: :female, department: "Engineering")
  end

  it "computes the overall male-vs-female gap percentage" do
    overall = described_class.new.call[:overall]

    expect(overall.dig(:genders, "male", :average_usd_cents)).to eq(10_000_000)
    expect(overall.dig(:genders, "female", :average_usd_cents)).to eq(9_000_000)
    expect(overall[:gap_pct]).to eq(10.0)
  end

  it "breaks the gap down by department" do
    engineering = described_class.new.call[:by_department].find { |d| d[:department] == "Engineering" }
    expect(engineering[:gap_pct]).to eq(10.0)
  end
end
