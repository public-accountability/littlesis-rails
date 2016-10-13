class NysController < ApplicationController
  before_filter :auth
  skip_before_action :verify_authenticity_token

  def candidates
  end

  def new_filer_entity
    @entity = Entity.find(entity_id)
  end

  # POST data:
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

  def entity_id
    params.require(:entity)
  end

  def match_params
    params.require(:payload).permit(:donor_id, :disclosure_ids => [])
  end
  
end
