module SalarySerializer
  module_function

  def call(salary, fx:)
    {
      id: salary.id,
      amount_cents: salary.amount_cents,
      amount: salary.amount,
      currency: salary.currency,
      amount_usd_cents: fx.to_usd_cents(salary.amount_cents, salary.currency),
      effective_date: salary.effective_date,
      current: salary.current
    }
  end
end
