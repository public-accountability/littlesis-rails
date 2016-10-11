class NysController < ApplicationController
  before_filter :auth
  skip_before_action :verify_authenticity_token

  def candidates
  end

  def new_filer
  end

  def match_donations
    check_permission 'importer'
    if request.post?
      render json: {'test'=> 123}
    end
  end
  
  # search for contributions
  # /nys/potential_contributions?entity=123
  def potential_contributions
    check_permission 'importer'
    name = Entity.find(params.require(:entity).to_i).name
    render json: NyDisclosure.search(name, :with => { :is_matched => false } )
  end
  
end
