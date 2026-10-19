require "rails_helper"

RSpec.describe Salary, type: :model do
  subject { build(:salary) }

  it { is_expected.to belong_to(:employee) }
  it { is_expected.to validate_presence_of(:effective_date) }
  it { is_expected.to validate_numericality_of(:amount_cents).only_integer.is_greater_than(0) }

  describe ".record_for" do
    let(:employee) { create(:employee) }

    it "makes the new salary current and supersedes the previous one" do
      first = Salary.record_for(employee, amount_cents: 5_000_000, currency: "usd", effective_date: 2.years.ago.to_date)
      expect(first.reload.current).to be(true)
      expect(first.currency).to eq("USD")

      second = Salary.record_for(employee, amount_cents: 6_000_000, currency: "USD", effective_date: 1.year.ago.to_date)

      expect(second.current).to be(true)
      expect(first.reload.current).to be(false)
      expect(employee.salaries.current.count).to eq(1)
    end
  end

  it "exposes a decimal amount" do
    expect(build(:salary, amount_cents: 12_345).amount).to eq(123.45)
  end
end
