module ApiHelpers
  def auth_headers(user)
    _session, token = Session.issue(user)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
