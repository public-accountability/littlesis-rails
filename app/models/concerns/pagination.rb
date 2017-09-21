module Pagination
  def paginate(page, per, count, records)
    Kaminari
      .paginate_array(records, total_count: count)
      .page(page)
      .per(per)
  end
end
