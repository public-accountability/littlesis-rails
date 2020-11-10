# frozen_string_literal: true

# Pages
# GET     /fec/entities/:id/contributions         "explore contributions page"
# GET     /fec/entities/:id/match_contributions   "match contributions page"
# GET     /fec/committies/:fec_id
# GET     /fec/candidates/:fec_id

# Endpoints
# POST    /fec/donor_match   { donor_id: <ENTITY_ID>, sub_ids: [] }
# DELETE  /fec/contribution_unmatch   { sub_id: <SUB_ID> }

# Services/Queries
#
# FECDonorQuery.new(entity)
# FECDonorMatchService.run(donor_id:, sub_ids:)
# FECContributionsQuery.run
#

class FECController < ApplicationController
  before_action :set_entity, only: %[contributions match_contributions]

  def contributions
    @contributions = FECContributionsQuery.run(@entity)
  end

  def match_contributions
    search_term = params[:q] || @entity.name_variations.join(' OR ')
    @donors = FECDonorQuery.run(search_term)
  end

  # required params: donor_id, sub_ids
  def donor_match
    FECDonorMatchService.run(donor_id: params[:donor_id], sub_ids: params[:sub_ids])
  end

  def contribution_unmatch
  end

  def committee
  end

  def candidate
  end
end
