# frozen_string_literal: true

class PagesConstraint
  PAGES = %w[
    /about
    /features
    /team
    /disclaimer
    /about/edit
    /features/edit
    /team/edit
    /disclaimer/edit
  ].freeze

  def matches?(request)
    PAGES.include?(request.fullpath)
  end
end
