# frozen_string_literal: true

module Pagination
  def paginate(page, per, records, count = nil)
    Pagination.paginate(page, per, records, count)
  end

  # count is optional. we can normally infer it from records,
  # but expose it as param in case SQL lookups are separate
  def self.paginate(page, per, records, count = nil)
    Kaminari
      .paginate_array(records, total_count: count || records.count)
      .page(page)
      .per(per)
  end
end
