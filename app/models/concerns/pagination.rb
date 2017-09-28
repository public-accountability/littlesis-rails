module Pagination
  # count is optionalwe can normally infer it from records,
  # but expose it as param in case SQL lookups are separate
  def paginate(page, per, records, count = nil)
    Kaminari
      .paginate_array(records, total_count: count || records.count)
      .page(page)
      .per(per)
  end
end
