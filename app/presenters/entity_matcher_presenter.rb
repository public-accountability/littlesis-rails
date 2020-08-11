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

  # input: ExternalRelationshipPresenter
  # output: [ <EntityMatcherPresenter>, <EntityMatcherPresenter> ]
  def self.for_external_relationship(er, search_entity1: nil, search_entity2: nil)
    [
      new(
        :model => er,
        :matches_method => :potential_matches_entity1,
        :search_method => :potential_matches_entity1,
        :search_param => 'search_entity1',
        :search_term => search_entity1,
        :match_url => external_relationship_path(er, entity_side: 1),
        :search_url => external_relationship_path(er, entity_side: 1),
        :matched? => er.entity1_matched?,
        :active_tab => :matches
      ),
      new(
        :model => er,
        :matches_method => :potential_matches_entity2,
        :search_method => :potential_matches_entity2,
        :search_param => 'search_entity2',
        :search_term => search_entity2,
        :match_url => external_relationship_path(er, entity_side: 2),
        :search_url => external_relationship_path(er, entity_side: 2),
        :matched? => er.entity2_matched?,
        :active_tab => :matches
      )
    ].tap do |matchers|
      case er.dataset
      when 'iapd_schedule_a'
        matchers[0].title = er.data_summary['Name']
        matchers[0].primary_ext = er.external_data.wrapper.owner_primary_ext
        matchers[1].title = er.data_summary['Advisor']
        matchres[1].primary_ext = 'Org'
      when 'nys_disclosure'
        matchers[0].title = er.external_data.wrapper.name
        matchers[0].primary_ext = er.external_data.wrapper.donor_primary_ext
        matchers[1].title = er.external_data.wrapper.filer_name
        matchers[1].primary_ext = er.external_data.wrapper.recipient_primary_ext
      end
    end
  end

  private_class_method def self.external_relationship_path(*args, **kwargs)
    Rails.application.routes.url_helpers.external_relationship_path(*args, **kwargs)
  end
end
