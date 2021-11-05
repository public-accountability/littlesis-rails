# frozen_string_literal: true

# Pages
# GET     /fec/entities/:id/match_contributions
# Information
# GET     /fec/entities/:id/contributions
# GET     /fec_match/:id
# GET     /fec/committies/:cmte_id
# GET     /fec/candidates/:cand_id
# Action
#   the action routes return Turbo Frames. See views/_fec_contribution_actions.
# POST    /fec/fec_matches { entity_id:, fec_contribution_id: }
# POST    /fec/fec_contributions/:id/hide_entity { entity_id }
# POST    /fec/fec_contributions/:id/show_entity { entity_id }
# POST    /fec/fec_contributions/clear_hidden { entity_id }
# DELETE  /fec/fec_matches/:id
class FECController < ApplicationController
  before_action :user_is_matcher?, except: %i[contributions committee candidate]

  def contributions
    render json: FECMatch.joins(:fec_contribution).where(donor_id: params[:id]).map(&:fec_contribution)
  end

  def match_contributions
    @entity = Entity.find(params[:id])
    @query = params[:query]&.strip

    if @query.present?
      @contributions = ExternalDataset
                         .fec_contributions
                         .includes(:fec_match)
                         .where("fec_year >= 2020")
                         .search_by_name(@query)
                         .limit(3000)
                         .map(&:as_presenter)
    end
  end

  def create_fec_match
    @entity = Entity.find(params[:entity_id])
    @fec_contribution = ExternalDataset.fec_contributions.find(params[:fec_contribution_id])
    FECMatch.create!(donor: @entity, fec_contribution: @fec_contribution)
    render partial: 'fec_contribution_actions', locals: { fec_contribution: @fec_contribution.as_presenter, entity_id: @entity.id }
  end

  def delete_fec_match
    @fec_match = FECMatch.find(params[:id])
    @fec_contribution = @fec_match.fec_contribution
    @entity = @fec_match.donor
    @fec_match.destroy!
    render partial: 'fec_contribution_actions', locals: { fec_contribution: @fec_contribution.reload.as_presenter, entity_id: @entity.id }
  end

  def hide_entity
    @fec_contribution = ExternalDataset.fec_contributions.find(params[:id])
    @entity = Entity.find(params.require(:entity_id))
    @fec_contribution.hide_entity(@entity)
    render partial: 'fec_contribution_actions', locals: { fec_contribution: @fec_contribution.reload.as_presenter, entity_id: @entity.id }
  end

  def show_entity
    @fec_contribution = ExternalDataset.fec_contributions.find(params[:id])
    @entity = Entity.find(params.require(:entity_id))
    @fec_contribution.show_entity(@entity)
    render partial: 'fec_contribution_actions', locals: { fec_contribution: @fec_contribution.reload.as_presenter, entity_id: @entity.id }
  end

  # def clear_hidden
  #   # @entity = Entity.find(params.require(:entity_id))
  # end

  def fec_match
    render json: FECMatch.find(params[:id])
  end

  def committee
    model = if params[:fec_year].present?
              ExternalDataset::FECCommittee.find_by(fec_year: params[:fec_year], cmte_id: params[:cmte_id])
            else
              ExternalDataset::FECCommittee.order(fec_year: :desc).find_by(cmte_id: params[:cmte_id])
            end

    render json: model
  end

  def candidate
    model = if params[:fec_year].present?
              ExternalDataset::FECCandidate.find_by(fec_year: params[:fec_year], cand_id: params[:cand_id])
            else
              ExternalDataset::FECCandidate.order(fec_year: :desc).find_by(cand_id: params[:cand_id])
            end

    render json: model
  end

  private

  def user_is_matcher?
    unless user_signed_in? && current_user.matcher?
      raise Exceptions::PermissionError
    end
  end
end
