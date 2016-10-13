class NysController < ApplicationController
  before_filter :auth

  def candidates
  end

  def create
    check_permission 'importer'
    
    ny_filer_ids.each do |id|
      filer_id = NyFiler.find(id).filer_id
      NyFilerEntity.create!(entity_id: entity_id, ny_filer_id: id, filer_id: filer_id)
    end
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
    
    head :accepted
  end
  
  def unmatch_donations
    check_permission 'importer'
  end

  # search for contributions
  # /nys/potential_contributions?entity=123
  def potential_contributions
    check_permission 'importer'
    name = Entity.find(params.require(:entity).to_i).name
    render json: NyDisclosure.potential_contributions(name)
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
