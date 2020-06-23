# frozen_string_literal: true

attributes = %i[model matches_method search_param search_method title name primary_ext active_tab matches match_url search_url search_term search_matches matched?]

EntityMatcherPresenter = Struct.new(*attributes, keyword_init: true) do
  def initialize(**kwargs)
    super(**kwargs)
    self.matches_method = :matches unless matches_method
    self.search_method = :search_for_matches unless search_method
    self.search_param = 'search' unless search_param

    # If unmatched this will populate the attribute matches
    # using a dataset specific
    unless matched? || matches
      self.matches = model.public_send(matches_method)
    end

    if search_term.present?
      self.search_matches = model.public_send(search_method, search_term)
      self.active_tab = :search
    end
  end
end
