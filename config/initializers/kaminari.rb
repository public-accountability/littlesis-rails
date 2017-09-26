module Kaminari
  class PaginatableArray
    def map(&block)
      self.class.new(super(&block), get_options)
    end

    private

    def get_options
      {
        limit: @_limit_value,
        offset: @_offset_value,
        total_count: @_total_count,
        padding: @_padding
      }
    end
  end
end

Kaminari.configure do |config|
  config.default_per_page = 10
  config.max_per_page = 50
  config.window = 3
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end
