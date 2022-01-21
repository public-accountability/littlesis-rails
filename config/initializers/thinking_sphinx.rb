# frozen_string_literal: true

# for manticore 4.2. see https://github.com/pat/thinking-sphinx/pull/1213
module ThinkingSphinx
  module Masks
    class PaginationMask
      def total_pages
        return 0 if search.meta['total'].nil?

        @total_pages ||= (total_entries / search.per_page.to_f).ceil
      end
    end
  end
end
