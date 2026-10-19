module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate!, only: :create

      rate_limit to: 10, within: 3.minutes, only: :create,
        with: -> { render json: { error: "too_many_requests" }, status: :too_many_requests }

      def create
        user = User.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password].to_s)

        if user
          _session, token = Session.issue(user)
          render json: { token: token, user: user_json(user) }, status: :created
        else
          render json: { error: "invalid_credentials" }, status: :unauthorized
        end
      end

      def show
        render json: { user: user_json(current_user) }
      end

      def destroy
        current_session&.destroy
        head :no_content
      end

      private

      def user_json(user)
        { id: user.id, email: user.email, role: user.role }
      end
    end
  end
end
