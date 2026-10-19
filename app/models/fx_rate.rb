class FxRate < ApplicationRecord
  normalizes :currency, with: ->(currency) { currency.strip.upcase }

  validates :currency, presence: true, uniqueness: true, length: { is: 3 }
  validates :rate_to_usd, presence: true, numericality: { greater_than: 0 }
  validates :as_of, presence: true
end
