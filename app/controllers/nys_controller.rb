# frozen_string_literal: true

class NYSController < ApplicationController
  before_action :authenticate_user!

  IMPORTER_ACTIONS = %i[create create_ny_filer_entity match_donations
                        unmatch_donations potential_contributions contributions].freeze

  before_action -> { check_permission 'importer' }, only: IMPORTER_ACTIONS

  def index; end

  def candidates; end

  def pacs; end

  def match; end

  def datatable
    render json: Datatable.json_for(:NyFiler, datatable_params)
  end

  # POST /nys/pacs/new
  # POST /nys/candidates/new
  # Creates one or more NyFilerEntity
  def create
    params.require(:ids).each do |id|
      filer_id = NyFiler.find(id).filer_id
      NyFilerEntity.create!(entity_id: entity_id, ny_filer_id: id, filer_id: filer_id)
    end
    Entity.find(entity_id).update(last_user_id: current_user.id)
    redirect_to :action => 'new_filer_entity', :entity => entity_id
  end

  # POST /nys/ny_filer_entity
  # similar to +create+, but only creates a singular entity and returns json
  # intended to be used with the Entity Match Table
  def create_ny_filer_entity
    NyFilerEntity.create!(new_ny_filer_entity_params)
    head :created
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn e
    head :not_found
  rescue NyFiler::AlreadyMatchedError
    head :bad_request
  end

  def new_filer_entity
    @entity = Entity.find(entity_id)
    @matched = Set.new
    @filers = Set.new
    NyFiler.public_send(search_filers_or_pacs, sphinx_search_query).each(&method(:filter_filers))
    # add all already matched filers that aren't found up via the search
    NyFilerEntity.where(entity_id: entity_id).each { |f| @matched << f.ny_filer }
  end

  # POST data
  #  { payload: {
  #       disclosure_ids: [int],
  #       donor_id: int }
  #   }
  #
  def match_donations
    match_params[:disclosure_ids].each do |disclosure_id|
      NyMatch.match(disclosure_id, match_params[:donor_id], current_user.id)
    end
    NyDisclosure.update_delta_flag(match_params[:disclosure_ids])
    Entity.find(match_params[:donor_id]).update(last_user_id: current_user.id)
    render json: { status: 'ok' }, status: :accepted
  end

  # POST data
  #  { payload: {
  #       ny_match_ids: [int],
  #   }
  def unmatch_donations
    unmatch_params[:ny_match_ids].each do |i|
      NyMatch.find(i.to_i).unmatch!
    end
    render json: { status: 'ok' }
  end

  # search for contributions
  # /nys/potential_contributions?entity=123
  def potential_contributions
    entity = Entity.find(params.require(:entity).to_i)
    render json: NyDisclosure.potential_contributions(entity)
  end

  # Already matched donations
  # /nys/contributions?entity=123
  def contributions
    render json: NyMatch.where(donor_id: entity_id).map(&:info)
  end

  private

  def search_filers_or_pacs
    return :search_pacs if @entity.org?
    return :search_filers if @entity.person?
  end

  def filter_filers(filer)
    if filer.is_matched?
      @matched << filer
    else
      @filers << filer
    end
  end

  def sphinx_search_query
    if params[:query]
      LsSearch.escape(params[:query])
    elsif @entity.person?
      @entity.person.name_last
    else
      @entity.name
    end
  end

  def entity_id
    params.require(:entity)
  end

  def match_params
    params.require(:payload).permit(:donor_id, :disclosure_ids => [])
  end

  def unmatch_params
    params.require(:payload).permit(:ny_match_ids => [])
  end

  def new_ny_filer_entity_params
    entity = Entity.find(params.require(:entity_id))
    ny_filer = NyFiler.find(params.require(:id))
    ny_filer.raise_if_matched!

    { entity_id: entity.id, ny_filer_id: ny_filer.id, filer_id: ny_filer.filer_id }
  end

  # In theory we should be sending requests from our client
  # that don't require doing "manual" conversion of hash into arrays
  # see: https://stackoverflow.com/questions/6410810/rails-not-decoding-json-from-jquery-correctly-array-becoming-a-hash-with-intege
  # However, this doesn't seem to work without going DEEP into
  # the datatable source code, so let's just deal with it.
  def datatable_params
    h = params.to_unsafe_h
    # If this problem gets fixed client-side and/or while testing
    return h if h['columns'].is_a?(Array)

    h['columns'] = h['columns'].sort.map(&:second)
    h
  end
end
