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

  # Takes a list of Entity ids and gathers the most recent
  # refences for those entities and their relationships
  # It also includes the most recent references regardless if they are
  # associated with the entities or not
  def recent
    relationship_ids = Entity.find(entity_ids).map { |e| e.links.map { |l| l.relationship_id } }.flatten.uniq
    recent_reference_query = [ { :class_name => 'Entity', :object_ids => entity_ids } ]
    recent_reference_query.append({ :class_name => 'Relationship', :object_ids => relationship_ids }) unless relationship_ids.empty?
    render json: (Reference.last(2) + Reference.recent_references(recent_reference_query, 20)).uniq
  end

  private

  def entity_ids
    if params[:entity_ids].is_a?(String)
      params[:entity_ids].split(",").map(&:to_i).uniq
    else
      params[:entity_ids].map(&:to_i).uniq
    end
  end

  def reference_params
    params.require(:data).permit(:object_id, :object_model, :source, :name, :fields, :source_detail, :publication_date, :ref_type)
  end

  def excerpt_params
    params.require(:data).permit(:excerpt)
  end
end
