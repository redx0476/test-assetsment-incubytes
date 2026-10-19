class Session < ApplicationRecord
  DEFAULT_TTL = 2.weeks

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  def self.issue(user, ttl: DEFAULT_TTL)
    raw_token = SecureRandom.urlsafe_base64(32)
    session = create!(user: user, token_digest: digest(raw_token), expires_at: ttl.from_now)
    [ session, raw_token ]
  end

  def self.authenticate(raw_token)
    return if raw_token.blank?

    session = find_by(token_digest: digest(raw_token))
    session unless session.nil? || session.expired?
  end

  def expired?
    expires_at.present? && expires_at.past?
  end
end
