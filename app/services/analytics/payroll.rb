module Analytics
  class Payroll
    BUCKET_SQL = <<~SQL.freeze
      CASE
        WHEN #{USD_CENTS} < 5000000  THEN '< $50k'
        WHEN #{USD_CENTS} < 10000000 THEN '$50k–$100k'
        WHEN #{USD_CENTS} < 15000000 THEN '$100k–$150k'
        WHEN #{USD_CENTS} < 20000000 THEN '$150k–$200k'
        ELSE '$200k+'
      END
    SQL

    def call
      headcount, total, average, median = Analytics.base_scope.pick(
        Arel.sql("COUNT(*)"),
        Arel.sql("COALESCE(SUM(#{USD_CENTS}), 0)"),
        Arel.sql("COALESCE(AVG(#{USD_CENTS}), 0)"),
        Analytics.median_sql
      )

      {
        headcount: headcount,
        total_usd_cents: total.to_i,
        average_usd_cents: average.to_i,
        median_usd_cents: median.to_i,
        distribution: distribution
      }
    end

    private

    def distribution
      Analytics.base_scope
               .group(Arel.sql(BUCKET_SQL))
               .order(Arel.sql("MIN(#{USD_CENTS})"))
               .count
               .map { |bucket, count| { bucket: bucket, headcount: count } }
    end
  end
end
