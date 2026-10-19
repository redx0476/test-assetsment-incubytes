require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  before { create(:fx_rate, currency: "USD", rate_to_usd: 1.0) }

  describe "GET /api/v1/employees" do
    it "requires authentication" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:unauthorized)
    end

    it "paginates and returns summaries with the current salary" do
      create_list(:employee, 3, :with_salary, amount_cents: 9_000_000, currency: "USD")

      get "/api/v1/employees", params: { per_page: 2 }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["employees"].size).to eq(2)
      expect(response.parsed_body["meta"]).to include("total_count" => 3, "total_pages" => 2, "page" => 1)
      expect(response.parsed_body["employees"].first.dig("current_salary", "amount_usd_cents")).to eq(9_000_000)
    end

    it "filters by search term and country" do
      match = create(:employee, first_name: "Ada", country_code: "GB")
      create(:employee, first_name: "Bob", country_code: "US")

      get "/api/v1/employees", params: { q: "Ada", country: "GB" }, headers: headers

      ids = response.parsed_body["employees"].map { |e| e["id"] }
      expect(ids).to eq([ match.id ])
    end
  end

  describe "GET /api/v1/employees/:id" do
    it "returns detail with salary history and band assessment" do
      employee = create(:employee, country_code: "US", job_level: :mid)
      create(:pay_band, country_code: "US", job_level: :mid, min_cents: 8_000_000, mid_cents: 10_000_000, max_cents: 12_000_000)
      Salary.record_for(employee, amount_cents: 7_000_000, currency: "USD", effective_date: 2.years.ago.to_date)
      Salary.record_for(employee, amount_cents: 11_000_000, currency: "USD", effective_date: 1.year.ago.to_date)

      get "/api/v1/employees/#{employee.id}", headers: headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body["employee"]
      expect(body["salaries"].size).to eq(2)
      expect(body.dig("band_assessment", "status")).to eq("within_band")
      expect(body.dig("band_assessment", "compa_ratio")).to eq(1.1)
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee" do
      params = { employee: attributes_for(:employee, email: "new@acme.test", employee_number: "ACME-999999") }

      expect {
        post "/api/v1/employees", params: params, headers: headers
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "returns validation errors for invalid input" do
      post "/api/v1/employees", params: { employee: { email: "" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "soft-deletes by marking the employee terminated" do
      employee = create(:employee, employment_status: :active)

      delete "/api/v1/employees/#{employee.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(employee.reload).to be_terminated
    end
  end
end
