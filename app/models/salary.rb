class Salary < ApplicationRecord
  belongs_to :employee

  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :effective_date, presence: true

  scope :current, -> { where(current: true) }

  def self.record_for(employee, amount_cents:, currency:, effective_date:)
    transaction do
      employee.salaries.current.update_all(current: false, updated_at: Time.current)
      employee.salaries.create!(
        amount_cents: amount_cents,
        currency: currency.to_s.upcase,
        effective_date: effective_date,
        current: true
      )
    end
  end

  def amount
    amount_cents / 100.0
  end
end
