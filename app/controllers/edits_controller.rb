# frozen_string_literal: true

class EditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: [:index, :entity]
  before_action :set_entity, only: [:entity]

  def index
    @edits = Entity
             .includes(last_user: :user)
             .order("updated_at DESC").page(@page).per(10)
  end

  def entity
  end

  private

  def set_page
    @page = params[:page].presence&.to_i || 1
  end

  def rel_versions(entity_id, page, per_page = 5)
    raise ArgumentError unless entity_id.is_a? Integer
    PaperTrail::Version
      .where("entity1_id = #{entity_id} OR entity2_id = #{entity_id}")
      .order(created_at: :desc)
      .page(page)
      .per(per_page)
  end
end
