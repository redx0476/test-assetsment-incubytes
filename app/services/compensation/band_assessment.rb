module Compensation
  class BandAssessment
    def self.for(employee)
      new(employee).call
    end

    def initialize(employee)
      @salary = employee.current_salary
      @band = PayBand.for(job_level: employee.job_level, country_code: employee.country_code)
    end

    def call
      return { status: "no_salary", compa_ratio: nil, band: nil } if @salary.nil?
      return { status: "no_band", compa_ratio: nil, band: nil } if @band.nil?

      { status: status, compa_ratio: compa_ratio, band: band_json }
    end

    private

    def compa_ratio
      (@salary.amount_cents.to_f / @band.mid_cents).round(4)
    end

    def status
      return "below_min" if @salary.amount_cents < @band.min_cents
      return "above_max" if @salary.amount_cents > @band.max_cents

      "within_band"
    end

    def band_json
      {
        currency: @band.currency,
        min_cents: @band.min_cents,
        mid_cents: @band.mid_cents,
        max_cents: @band.max_cents
      }
    end
  end
end
