module Api
  module V1
    module Analytics
      class BreakdownsController < BaseController
        def show
          render json: ::Analytics::Breakdown.new(params[:dimension]).call
        end
      end
    end
  end
end
