class EmployeesQuery
  SORT_COLUMNS = {
    "name" => "last_name",
    "country" => "country_code",
    "department" => "department",
    "level" => "job_level",
    "hired" => "hire_date"
  }.freeze

  def initialize(relation = Employee.all)
    @relation = relation
  end

  def call(params)
    scope = @relation.search(params[:q])
    scope = scope.where(country_code: params[:country]) if params[:country].present?
    scope = scope.where(department: params[:department]) if params[:department].present?
    scope = scope.where(job_level: params[:job_level]) if Employee.job_levels.key?(params[:job_level].to_s)
    scope = scope.where(employment_status: params[:status]) if Employee.employment_statuses.key?(params[:status].to_s)
    scope.order(sort_clause(params[:sort], params[:direction]))
  end

  private

  def sort_clause(sort, direction)
    column = SORT_COLUMNS.fetch(sort.to_s, "last_name")
    direction = direction.to_s == "desc" ? "desc" : "asc"
    Arel.sql("#{column} #{direction}, id asc")
  end
end
