# frozen_string_literal: true

EntityMatcherPresenter = Struct.new(
  :model, :title, :name, :primary_ext, :active_tab, :matches, :match_url, :search_url, :search_term, :search_matches, :matched?,
  keyword_init: true
) do

  def initialize(**kwargs)
    super(**kwargs)
    unless matched?
      self.matches = model.matches

      if search_term.present?
        self.search_matches = model.search_for_matches(search_term)
        self.active_tab = :search
      end
    end
  end
end
