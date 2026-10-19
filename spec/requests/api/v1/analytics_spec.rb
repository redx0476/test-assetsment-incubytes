require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  before do
    create(:fx_rate, currency: "USD", rate_to_usd: 1.0)
    create(:employee, :with_salary, amount_cents: 10_000_000, currency: "USD", country_code: "US")
  end

  it "requires authentication" do
    get "/api/v1/analytics/dashboard"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns dashboard KPIs" do
    get "/api/v1/analytics/dashboard", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("headcount", "total_usd_cents", "median_usd_cents", "distribution")
  end

  it "returns a breakdown for the requested dimension" do
    get "/api/v1/analytics/breakdown", params: { dimension: "department" }, headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["dimension"]).to eq("department")
  end

  it "returns the equity report" do
    get "/api/v1/analytics/equity", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("overall", "by_department")
  end
end
