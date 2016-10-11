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
  
end
