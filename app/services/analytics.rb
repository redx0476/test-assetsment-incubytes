module Analytics
  USD_CENTS = "salaries.amount_cents * fx_rates.rate_to_usd".freeze

  module_function

  def base_scope
    Employee.active
            .joins("INNER JOIN salaries ON salaries.employee_id = employees.id AND salaries.current = TRUE")
            .joins("INNER JOIN fx_rates ON fx_rates.currency = salaries.currency")
  end

  def median_sql
    Arel.sql("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY #{USD_CENTS})")
  end
end
