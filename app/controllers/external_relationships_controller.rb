# frozen_string_literal: true

class ExternalRelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_relationship, only: %i[show update]

  def show
    @entity_matchers = EntityMatcherPresenter
                         .for_external_relationship(@external_relationship,
                                                    search_entity1: params['search_entity1'],
                                                    search_entity2: params['search_entity2'])
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
