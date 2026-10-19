require "rails_helper"

RSpec.describe Session, type: :model do
  it { is_expected.to belong_to(:user) }

  describe ".issue" do
    it "returns a raw token and stores only its digest" do
      user = create(:user)
      session, raw_token = Session.issue(user)

      expect(raw_token).to be_present
      expect(session.token_digest).to eq(Session.digest(raw_token))
      expect(session.token_digest).not_to eq(raw_token)
      expect(session.expires_at).to be_within(1.minute).of(Session::DEFAULT_TTL.from_now)
    end
  end

  describe ".authenticate" do
    it "returns the session for a valid token" do
      user = create(:user)
      session, raw_token = Session.issue(user)
      expect(Session.authenticate(raw_token)).to eq(session)
    end

    it "returns nil for an unknown, blank, or expired token" do
      user = create(:user)
      _session, raw_token = Session.issue(user)

      expect(Session.authenticate("nope")).to be_nil
      expect(Session.authenticate(nil)).to be_nil

      create(:session, :expired, user: user, token_digest: Session.digest("expired-token"))
      expect(Session.authenticate("expired-token")).to be_nil
      expect(Session.authenticate(raw_token)).to be_present
    end
  end
end
