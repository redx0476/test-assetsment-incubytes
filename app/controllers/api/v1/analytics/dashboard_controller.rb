module Api
  module V1
    module Analytics
      class DashboardController < BaseController
        def show
          render json: ::Analytics::Payroll.new.call
        end
      end
    end
  end
end
