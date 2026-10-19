module Analytics
  class Equity
    def call
      { overall: overall, by_department: by_department }
    end

    private

    def overall
      rows = Analytics.base_scope.group("employees.gender").pluck(
        Arel.sql("employees.gender"), Arel.sql("COUNT(*)"), Arel.sql("AVG(#{USD_CENTS})")
      )
      build_gap(rows)
    end

    def by_department
      Analytics.base_scope
               .group("employees.department", "employees.gender")
               .pluck(
                 Arel.sql("employees.department"),
                 Arel.sql("employees.gender"),
                 Arel.sql("COUNT(*)"),
                 Arel.sql("AVG(#{USD_CENTS})")
               )
               .group_by(&:first)
               .map { |department, dept_rows|
                 build_gap(dept_rows.map { |row| row[1..] }).merge(department: department)
               }
               .sort_by { |entry| entry[:department] }
    end

    def build_gap(rows)
      genders = rows.each_with_object({}) do |(gender_value, count, average), memo|
        memo[gender_label(gender_value)] = { headcount: count, average_usd_cents: average.to_i }
      end

      {
        genders: genders,
        gap_pct: gap_pct(genders.dig("male", :average_usd_cents), genders.dig("female", :average_usd_cents))
      }
    end

    def gap_pct(male_average, female_average)
      return nil if male_average.nil? || female_average.nil? || male_average.zero?

      ((male_average - female_average).to_f / male_average * 100).round(2)
    end

    def gender_label(value)
      return "unknown" if value.nil?

      value.is_a?(Integer) ? (Employee.genders.key(value) || "unknown") : value.to_s
    end
  end
end
