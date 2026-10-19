require "rails_helper"

RSpec.describe "Api::V1::Salaries", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  before { create(:fx_rate, currency: "USD", rate_to_usd: 1.0) }

  describe "POST /api/v1/employees/:employee_id/salaries" do
    it "records a new current salary and supersedes the previous one" do
      employee = create(:employee, :with_salary, amount_cents: 8_000_000, currency: "USD")

      post "/api/v1/employees/#{employee.id}/salaries",
        params: { salary: { amount_cents: 9_500_000, currency: "USD", effective_date: Date.current } },
        headers: headers

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("salary", "current")).to be(true)
      expect(employee.salaries.current.count).to eq(1)
      expect(employee.current_salary.amount_cents).to eq(9_500_000)
    end

    it "rejects a non-positive amount" do
      employee = create(:employee)

      post "/api/v1/employees/#{employee.id}/salaries",
        params: { salary: { amount_cents: 0, currency: "USD", effective_date: Date.current } },
        headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
