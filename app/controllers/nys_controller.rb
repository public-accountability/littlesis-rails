class NysController < ApplicationController
  before_filter :authenticate_user!
  before_action -> { check_permission 'importer' }, only: [
    :match_donations, :unmatch_donations, :potential_contributions, :contributions
  ]

  def index
  end

  def candidates
  end

  def pacs
  end

  def create
    check_permission 'importer'

    ny_filer_ids.each do |id|
      filer_id = NyFiler.find(id).filer_id
      NyFilerEntity.create!(entity_id: entity_id, ny_filer_id: id, filer_id: filer_id)
    end
    Entity.find(entity_id).update(last_user_id: current_user.sf_guard_user.id)
    redirect_to :action => "new_filer_entity", :entity => entity_id
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
    Entity.find(match_params[:donor_id]).update(last_user_id: current_user.sf_guard_user_id)
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
      ThinkingSphinx::Query.escape(params[:query])
    elsif @entity.person?
      @entity.person.name_last
    else
      @entity.name
    end
  end

  def ny_filer_ids
    params.require(:ids)
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
end
