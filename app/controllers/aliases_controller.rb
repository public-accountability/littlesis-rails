# frozen_string_literal: true

class AliasesController < ApplicationController
  include EntitiesHelper

  before_action :authenticate_user!
  before_action :set_alias, only: [:make_primary, :destroy]

  def create
    entity = Entity.find(alias_params.fetch('entity_id'))
    as = Alias.new(alias_params)
    if as.save
      redirect_to concretize_edit_entity_path(entity)
    else
      redirect_to concretize_edit_entity_path(entity), flash: { alert: as.errors.full_messages[0] }
    end
  end

  def update
  end

  def make_primary
    @alias.make_primary
    redirect_to concretize_edit_entity_path(@alias.entity)
  end

  def destroy
    @alias.destroy unless @alias.is_primary?
    redirect_to concretize_edit_entity_path(@alias.entity)
  end

  private

  def set_alias
    @alias = Alias.find(params[:id]).tap { |a| a.current_user = current_user }
  end

  def alias_params
    params.require(:alias).permit(:name, :entity_id)
  end
end
