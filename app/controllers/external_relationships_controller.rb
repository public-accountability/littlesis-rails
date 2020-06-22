# frozen_string_literal: true

class ExternalRelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_relationship, only: [:show]

  def show
    @entity_matchers = [
      EntityMatcherPresenter.new(
        :model => @external_relationship,
        :matches_method => :potential_matches_entity1,
        :search_term => params[:search],
        :match_url => external_relationship_path(@external_relationship),
        :search_url => external_relationship_path(@external_relationship),
        :matched? => @external_relationship.entity1_matched?,
        :active_tab => :matches
      )
    ]
  end

  def random
    redirect_to action: :show,
                id: ExternalRelationship.unmatched.order('RAND()').limit(1).pluck(:id).first
  end

  private

  def set_external_relationship
    @external_relationship = ExternalRelationship.find(params.require(:id)).presenter
  end
end
