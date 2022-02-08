# frozen_string_literal: true

class Link
  class GroupedLinkArray < SimpleDelegator
    PER_PAGE = 10
    attr_reader :subcategory

    # String/Symbol, [<Link>]
    def initialize(subcategory, links)
      @subcategory = subcategory.to_sym
      grouped_links = links.group_by(&:entity2_id).map { GroupedLink.new(*_2) }.sort!.reverse!
      super(grouped_links)
    end

    def total_pages
      (length / PER_PAGE.to_f).ceil
    end

    def additional_pages?
      total_pages > 1
    end

    def subcategory_name
      ProfilePage.subcategory_name(@subcategory)
    end

    def page(i)
      slice((i - 1) * PER_PAGE, PER_PAGE)
    end
  end
end
