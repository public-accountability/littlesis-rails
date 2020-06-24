# frozen_string_literal: true

class ExternalRelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_relationship, only: %i[show update]

  def show
    @entity_matchers = [
      EntityMatcherPresenter.new(
        :model => @external_relationship,
        :matches_method => :potential_matches_entity1,
        :search_method => :potential_matches_entity1,
        :search_param => 'search_entity1',
        :search_term => params['search_entity1'],
        :primary_ext => @external_relationship.external_data.wrapper.owner_primary_ext,
        :match_url => external_relationship_path(@external_relationship, entity_side: 1),
        :search_url => external_relationship_path(@external_relationship, entity_side: 1),
        :matched? => @external_relationship.entity1_matched?,
        :active_tab => :matches
      ),
      EntityMatcherPresenter.new(
        :model => @external_relationship,
        :matches_method => :potential_matches_entity2,
        :search_method => :potential_matches_entity2,
        :search_param => 'search_entity2',
        :search_term => params['search_entity2'],
        :primary_ext => 'Org',
        :match_url => external_relationship_path(@external_relationship, entity_side: 2),
        :search_url => external_relationship_path(@external_relationship, entity_side: 2),
        :matched? => @external_relationship.entity2_matched?,
        :active_tab => :matches
      )
    ]
  end

  def random
    redirect_to action: :show,
                id: ExternalRelationship.unmatched.order('RAND()').limit(1).pluck(:id).first
  end

  def update
    @external_relationship.match_from_params(entity_side: entity_side,
                                             params: params)
    redirect_to action: 'show'
  end

  private

  def set_external_relationship
    @external_relationship = ExternalRelationship.find(params.require(:id)).presenter
  end

  # 1 or 2
  def entity_side
    params.require(:entity_side).to_i.tap do |i|
      raise ArgumentError unless [1, 2].include?(i)
    end
  end
end
