module Api
  module V1
    class EmployeesController < BaseController
      include Paginatable

      def index
        scope = EmployeesQuery.new.call(params).includes(:current_salary)
        records, meta = paginate(scope)
        fx = FxConverter.new

        render json: {
          employees: records.map { |employee| EmployeeSerializer.summary(employee, fx: fx) },
          meta: meta
        }
      end

      def show
        employee = Employee.includes(:salaries).find(params[:id])

        render json: {
          employee: EmployeeSerializer.detail(
            employee,
            fx: FxConverter.new,
            assessment: Compensation::BandAssessment.for(employee)
          )
        }
      end

      def create
        employee = Employee.create!(employee_params)
        render json: { employee: EmployeeSerializer.summary(employee, fx: FxConverter.new) }, status: :created
      end

      def update
        employee = Employee.find(params[:id])
        employee.update!(employee_params)
        render json: { employee: EmployeeSerializer.summary(employee, fx: FxConverter.new) }
      end

      def destroy
        employee = Employee.find(params[:id])
        employee.update!(employment_status: :terminated)
        head :no_content
      end

      private

      def employee_params
        params.require(:employee).permit(
          :first_name, :last_name, :email, :employee_number, :country_code,
          :department, :job_title, :job_level, :gender, :hire_date, :employment_status
        )
      end
    end
  end
end
