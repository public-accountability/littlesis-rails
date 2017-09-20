module Pagination
  extend ActiveSupport::Concern

  def paginate(page, per, records, count)
    Kaminari
      .paginate_array(records, total_count: count)
      .page(page)
      .per(per)
  end
end
