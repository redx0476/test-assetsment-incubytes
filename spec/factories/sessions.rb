FactoryBot.define do
  factory :session do
    user
    token_digest { Session.digest(SecureRandom.urlsafe_base64(32)) }
    expires_at { Session::DEFAULT_TTL.from_now }

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
