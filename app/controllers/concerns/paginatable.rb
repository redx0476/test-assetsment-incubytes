module Paginatable
  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE = 100

  def paginate(scope)
    page = [ params[:page].to_i, 1 ].max
    per_page = params[:per_page].to_i
    per_page = DEFAULT_PER_PAGE if per_page <= 0
    per_page = [ per_page, MAX_PER_PAGE ].min

    total_count = scope.count(:all)
    records = scope.limit(per_page).offset((page - 1) * per_page)

    [ records, pagination_meta(page, per_page, total_count) ]
  end

  def pagination_meta(page, per_page, total_count)
    {
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_count.zero? ? 0 : (total_count.to_f / per_page).ceil
    }
  end
end
