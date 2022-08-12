# frozen_string_literal: true

module Kaminari
  class PaginatableArray
    def map(&block)
      options = { limit: @_limit_value,
                  offset: @_offset_value,
                  total_count: @_total_count,
                  padding: @_padding }

      self.class.new(super(&block), **options)
    end
  end
end

Kaminari.configure do |config|
  config.default_per_page = 10
  config.max_per_page = 300
  config.window = 3
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end
