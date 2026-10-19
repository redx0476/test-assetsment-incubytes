module Api
  class BaseController < ActionController::API
    before_action :authenticate!

    attr_reader :current_user, :current_session

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable

    private

    def authenticate!
      @current_session = Session.authenticate(bearer_token)
      @current_user = current_session&.user
      render_unauthorized unless current_user
    end

    def bearer_token
      request.authorization.to_s[/\ABearer (.+)\z/, 1]
    end

    def render_unauthorized
      render json: { error: "unauthorized" }, status: :unauthorized
    end

    def render_not_found(_error)
      render json: { error: "not_found" }, status: :not_found
    end

    def render_unprocessable(error)
      render json: { errors: error.record.errors.full_messages }, status: :unprocessable_content
    end
  end
end
