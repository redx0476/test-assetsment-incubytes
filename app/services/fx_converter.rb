class FxConverter
  class UnknownCurrencyError < StandardError; end

  def initialize(rates: nil)
    @rates = rates || load_rates
  end

  def to_usd_cents(amount_cents, currency)
    return 0 if amount_cents.nil?

    (amount_cents * rate_for(currency)).round
  end

  def rate_for(currency)
    @rates.fetch(currency.to_s.upcase) do
      raise UnknownCurrencyError, "No FX rate configured for #{currency.inspect}"
    end
  end

  private

  def load_rates
    FxRate.all.each_with_object({}) do |fx, rates|
      rates[fx.currency.upcase] = fx.rate_to_usd
    end
  end
end
