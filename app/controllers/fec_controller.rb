# frozen_string_literal: true

# Pages
# GET     /fec/entities/:id/contributions         "explore contributions page"
# GET     /fec/entities/:id/match_contributions   "match contributions page"

# GET     /fec/committies/:fec_id
# GET     /fec/candidates/:fec_id

# Endpoints
# POST    /fec/entities/123/donor_match { external_entity_id:  }
# DELETE  /fec/contribution_unmatch   { sub_id: <SUB_ID> }
class FECController < ApplicationController
  before_action :set_entity, only: %i[contributions match_contributions donor_match]

  def contributions; end

  def match_contributions
    @query = params[:query]

    if @query&.strip.present?
      @contributions = ExternalDataset
                         .fec_contributions
                         .where("fec_year >= 2020")
                         .search_by_name(@query)
                         .limit(2500)
                         .map { |x| FECContributionPresenter.new(x) }
    end
  end

  def donor_match
    FECMatch.create!(donor: @entity,
                     fec_contribution: ExternalDataset.fec_contributions.find(params[:fec_contribution_id]))

    redirect_to fec_entity_match_contributions_path(@entity, query: params[:query])
  end

  # def contribution_unmatch
  # end

  # def committee
  # end

  # def candidate
  # end
end
