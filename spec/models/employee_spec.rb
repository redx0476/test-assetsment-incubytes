require "rails_helper"

RSpec.describe Employee, type: :model do
  subject { build(:employee) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:department) }
  it { is_expected.to have_many(:salaries).dependent(:destroy) }

  it "requires a unique email, case-insensitively" do
    create(:employee, email: "dup@acme.test")
    duplicate = build(:employee, email: "DUP@ACME.TEST")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end

  it "requires a unique employee number" do
    existing = create(:employee)
    duplicate = build(:employee, employee_number: existing.employee_number)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:employee_number]).to be_present
  end
  it { is_expected.to define_enum_for(:employment_status).with_values(active: 0, on_leave: 1, terminated: 2) }

  describe "#current_salary" do
    it "returns the salary flagged current" do
      employee = create(:employee)
      Salary.record_for(employee, amount_cents: 5_000_000, currency: "USD", effective_date: 2.years.ago.to_date)
      latest = Salary.record_for(employee, amount_cents: 6_000_000, currency: "USD", effective_date: 1.year.ago.to_date)

      expect(employee.current_salary).to eq(latest)
    end
  end

  describe ".search" do
    it "matches on name, email, or employee number, case-insensitively" do
      match = create(:employee, first_name: "Ada", last_name: "Lovelace", email: "ada@acme.test")
      create(:employee, first_name: "Bob", last_name: "Smith", email: "bob@acme.test")

      expect(Employee.search("ada")).to contain_exactly(match)
      expect(Employee.search(match.employee_number)).to contain_exactly(match)
      expect(Employee.search("")).to include(match)
    end
  end

  it "builds a full name" do
    expect(build(:employee, first_name: "Grace", last_name: "Hopper").full_name).to eq("Grace Hopper")
  end
end
