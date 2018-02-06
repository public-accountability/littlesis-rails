class EditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entity, only: [:entity]

  def index
    @edits = Entity
             .includes(last_user: :user)
             .order("updated_at DESC").page(params[:page]).per(10)
  end

  def entity
    version_page = params[:version_page].presence || 1
    rel_page = params[:rel_page].presence || 1
    @versions = EntityHistory.new(@entity).versions.page(version_page).per(5)
    @relationship_changes = rel_versions(@entity.id, rel_page)
  end

  private

  def rel_versions(entity_id, page, per_page = 5)
    raise ArgumentError unless entity_id.is_a? Integer
    PaperTrail::Version
      .where("entity1_id = #{entity_id} OR entity2_id = #{entity_id}")
      .order(created_at: :desc)
      .page(page)
      .per(per_page)
  end
end
