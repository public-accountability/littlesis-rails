class EditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entity, only: [:entity]

  def index
    @edits = Entity
             .includes(last_user: :user)
             .order("updated_at DESC").page(params[:page]).per(10)
  end

  def entity
    page = params[:page].blank? ? 1 : params[:page]
    @versions = @entity.versions.reorder('created_at DESC').page(page).per(10)
    # @versions = @entity.versions.page(1).per(20)
    @relationship_changes = rel_versions(@entity.id, 1)
  end

  private

  def rel_versions(entity_id, page, per_page = 10)
    raise ArgumentError unless entity_id.is_a? Integer
    PaperTrail::Version
      .where("entity1_id = #{entity_id} OR entity2_id = #{entity_id}")
      .order(created_at: :desc)
      .page(1)
      .per(10)
  end

end
