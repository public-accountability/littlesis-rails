class NysController < ApplicationController
  before_filter :authenticate_user!

  def candidates
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
    @matched = []
    @filers = []
    NyFiler.search_filers(@entity.person.name_last).each { |filer| 
      if filer.is_matched?
        @matched << filer
      else
        @filers << filer
      end
    }
  end

  # POST data
  #  { payload: { 
  #       disclosure_ids: [int],
  #       donor_id: int }
  #   }
  # 
  def match_donations
    check_permission 'importer'
    
    match_params[:disclosure_ids].each do |disclosure_id| 
      NyMatch.match(disclosure_id, match_params[:donor_id], current_user.id)
    end
    NyDisclosure.update_delta_flag(match_params[:disclosure_ids])
    donor = Entity.find(match_params[:donor_id])
    donor.delay.clear_legacy_cache(request.host)
    donor.touch
    head :accepted
  end
  
  def unmatch_donations
    check_permission 'importer'
  end

  # search for contributions
  # /nys/potential_contributions?entity=123
  def potential_contributions
    check_permission 'importer'
    entity = Entity.find(params.require(:entity).to_i)
    render json: NyDisclosure.potential_contributions(entity)
  end

  # Already matched donations
  # /nys/contributions?entity=123
  def contributions
    check_permission 'importer'
    render json: NyMatch.where(donor_id: entity_id).map(&:info)
  end

  private

  def ny_filer_ids
    params.require(:ids)
  end

  def entity_id
    params.require(:entity)
  end

  def match_params
    params.require(:payload).permit(:donor_id, :disclosure_ids => [])
  end
  
end
