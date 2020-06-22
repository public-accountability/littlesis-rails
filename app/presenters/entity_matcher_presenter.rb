# frozen_string_literal: true

EntityMatcherPresenter = Struct.new(
  :model, :matches_method, :title, :name, :primary_ext, :active_tab, :matches, :match_url, :search_url, :search_term, :search_matches, :matched?,
  keyword_init: true
) do

  def initialize(**kwargs)
    super(**kwargs)
    self.matches_method = :matches unless matches_method

    # If unmatched this will populate the attribute matches
    # using a dataset specific
    unless matched? || matches
      self.matches = model.public_send(matches_method)
    end

    if search_term.present?
      self.search_matches = model.search_for_matches(search_term)
      self.active_tab = :search
    end
  end
end
