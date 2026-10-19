module Analytics
  class Breakdown
    DIMENSIONS = {
      "country" => "employees.country_code",
      "department" => "employees.department",
      "level" => "employees.job_level"
    }.freeze

    def initialize(dimension)
      @dimension = DIMENSIONS.key?(dimension.to_s) ? dimension.to_s : "country"
      @column = DIMENSIONS.fetch(@dimension)
    end

    def call
      rows = Analytics.base_scope
                      .group(Arel.sql(@column))
                      .order(Arel.sql("SUM(#{USD_CENTS}) DESC"))
                      .pluck(
                        Arel.sql(@column),
                        Arel.sql("COUNT(*)"),
                        Arel.sql("SUM(#{USD_CENTS})"),
                        Arel.sql("AVG(#{USD_CENTS})"),
                        Analytics.median_sql
                      )

      {
        dimension: @dimension,
        groups: rows.map { |key, count, total, average, median|
          {
            key: label(key),
            headcount: count,
            total_usd_cents: total.to_i,
            average_usd_cents: average.to_i,
            median_usd_cents: median.to_i
          }
        }
      }
    end

    private

    def label(key)
      return key unless @dimension == "level"

      key.is_a?(Integer) ? Employee.job_levels.key(key) : key.to_s
    end
  end
end
