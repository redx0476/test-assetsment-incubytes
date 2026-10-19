module EmployeeSerializer
  module_function

  def summary(employee, fx:)
    {
      id: employee.id,
      employee_number: employee.employee_number,
      full_name: employee.full_name,
      email: employee.email,
      country_code: employee.country_code,
      department: employee.department,
      job_title: employee.job_title,
      job_level: employee.job_level,
      employment_status: employee.employment_status,
      current_salary: employee.current_salary && SalarySerializer.call(employee.current_salary, fx: fx)
    }
  end

  def detail(employee, fx:, assessment:)
    summary(employee, fx: fx).merge(
      first_name: employee.first_name,
      last_name: employee.last_name,
      gender: employee.gender,
      hire_date: employee.hire_date,
      salaries: employee.salaries.sort_by(&:effective_date).reverse.map { |salary| SalarySerializer.call(salary, fx: fx) },
      band_assessment: assessment
    )
  end
end
