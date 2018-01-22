module PaginationExampleGroupHelper
  def stub_page_limit(klass, limit: 1, const: :PER_PAGE)
    before(:all) do
      klass.class_eval do
        @orginal_per_page = const_get(const)
        remove_const(const)
        const_set(const, limit)
      end
    end
    after(:all) do
      klass.class_eval do
        remove_const(const)
        const_set(const, @orginal_per_page)
      end
    end
  end
end
