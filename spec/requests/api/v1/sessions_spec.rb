require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/session" do
    it "issues a token for valid credentials (case-insensitive email)" do
      create(:user, email: "hr@acme.test", password: "password123")

      post "/api/v1/session", params: { email: "HR@ACME.test", password: "password123" }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["token"]).to be_present
      expect(response.parsed_body.dig("user", "email")).to eq("hr@acme.test")
    end

    it "rejects invalid credentials" do
      create(:user, email: "hr@acme.test", password: "password123")

      post "/api/v1/session", params: { email: "hr@acme.test", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("invalid_credentials")
    end
  end

  describe "GET /api/v1/session" do
    it "returns the current user with a valid token" do
      user = create(:user)

      get "/api/v1/session", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("user", "id")).to eq(user.id)
    end

    it "returns 401 without a token" do
      get "/api/v1/session"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/session" do
    it "revokes the token so it can no longer authenticate" do
      user = create(:user)
      _session, token = Session.issue(user)
      headers = { "Authorization" => "Bearer #{token}" }

      delete "/api/v1/session", headers: headers
      expect(response).to have_http_status(:no_content)

      get "/api/v1/session", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
