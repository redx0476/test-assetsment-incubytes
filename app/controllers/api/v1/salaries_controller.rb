module Api
  module V1
    class SalariesController < BaseController
      def create
        employee = Employee.find(params[:employee_id])
        salary = Salary.record_for(
          employee,
          amount_cents: salary_params[:amount_cents],
          currency: salary_params[:currency],
          effective_date: salary_params[:effective_date]
        )

        render json: { salary: SalarySerializer.call(salary, fx: FxConverter.new) }, status: :created
      end

      private

      def salary_params
        params.require(:salary).permit(:amount_cents, :currency, :effective_date)
      end
    end
  end
end
