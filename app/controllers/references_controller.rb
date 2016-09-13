class ReferencesController < ApplicationController
  before_filter :auth

  def create
    if Reference.create( reference_params.merge({last_user_id: current_user.sf_guard_user_id}) )
      render :nothing => true
    else
      # handle errors
      render :nothing => true  
    end
  end

  def destroy
  end

  private
  def reference_params
    params.permit(:object_id, :object_model, :source, :name, :fields, :source_detail, :publication_date, :ref_type)
  end

end
