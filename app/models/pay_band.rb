class PayBand < ApplicationRecord
  enum :job_level, Employee::JOB_LEVELS

  validates :country_code, presence: true, length: { is: 2 }
  validates :currency, presence: true, length: { is: 3 }
  validates :job_level, presence: true, uniqueness: { scope: :country_code }
  validates :min_cents, :mid_cents, :max_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :bounds_are_ordered

  def self.for(job_level:, country_code:)
    find_by(job_level: job_level, country_code: country_code)
  end

  private

  def bounds_are_ordered
    return if min_cents.blank? || mid_cents.blank? || max_cents.blank?
    return if min_cents <= mid_cents && mid_cents <= max_cents

    errors.add(:base, "pay band bounds must satisfy min <= mid <= max")
  end
end
