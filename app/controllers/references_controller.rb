class ReferencesController < ApplicationController
  before_filter :authenticate_user!

  def create
    ref = Reference.new( reference_params.merge({last_user_id: current_user.sf_guard_user_id}) )
    if ref.save
      params[:data][:object_model].constantize.find(params[:data][:object_id].to_i).touch
      unless excerpt_params['excerpt'].blank?
        ref.create_reference_excerpt(excerpt_params)
      end
      head :created
    else
      # send back errors
      render json: {errors: ref.errors}, status: :bad_request
    end
  end

  def destroy
    check_permission "deleter"
    begin
      Reference.find(params[:id]).destroy!
    rescue ActiveRecord::RecordNotFound
      head :bad_request
    else
      head :ok
    end
  end

  private
  def reference_params
    params.require(:data).permit(:object_id, :object_model, :source, :name, :fields, :source_detail, :publication_date, :ref_type)
  end

  def excerpt_params
    params.require(:data).permit(:excerpt)
  end
  
end
