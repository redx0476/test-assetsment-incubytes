class Employee < ApplicationRecord
  JOB_LEVELS = {
    junior: 0,
    mid: 1,
    senior: 2,
    staff: 3,
    principal: 4,
    manager: 5,
    director: 6
  }.freeze

  has_many :salaries, dependent: :destroy
  has_one :current_salary, -> { where(current: true) }, class_name: "Salary"

  enum :job_level, JOB_LEVELS
  enum :gender, { female: 0, male: 1, non_binary: 2, undisclosed: 3 }
  enum :employment_status, { active: 0, on_leave: 1, terminated: 2 }, default: :active

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :first_name, :last_name, :department, :job_title, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employee_number, presence: true, uniqueness: true
  validates :country_code, presence: true, length: { is: 2 }
  validates :hire_date, presence: true

  scope :search, ->(term) {
    next all if term.blank?

    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where(
      "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR employee_number ILIKE :q",
      q: pattern
    )
  }

  def full_name
    "#{first_name} #{last_name}"
  end
end
