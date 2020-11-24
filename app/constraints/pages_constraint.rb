# frozen_string_literal: true

class PagesConstraint
  PAGES = %w[about features team disclaimer newsletter].freeze

  def matches?(request)
    @regex ||= Regexp.new("/(#{PAGES.join('|')})")
    @regex.match? request.fullpath
  end
end
