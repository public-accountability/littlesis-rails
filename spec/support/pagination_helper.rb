module PaginationExampleGroupHelper
  def stub_page_limit(klass, limit = 1)
    before(:all) do
      klass.class_eval do
        @orginal_per_page = const_get(:PER_PAGE)
        remove_const(:PER_PAGE)
        const_set(:PER_PAGE, limit)
      end
    end
    after(:all) do
      klass.class_eval do
        remove_const(:PER_PAGE)
        const_set(:PER_PAGE, @orginal_per_page)
      end
    end
  end
end
