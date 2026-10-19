module Api
  module V1
    module Analytics
      class EquityController < BaseController
        def show
          render json: ::Analytics::Equity.new.call
        end
      end
    end
  end
end
