class AliasesController < ApplicationController
  before_action :authenticate_user!

  def create
    entity = Entity.find(alias_params.fetch('entity_id'))
    a = Alias.new(alias_params)
    if a.save
      redirect_to edit_entity_path(entity)
    else
      redirect_to edit_entity_path(entity), :flash => { :alert => a.errors.full_messages[0] }
    end
  end

  def update
  end

  def make_primary
    a = Alias.find(params[:id])
    a.make_primary
    redirect_to edit_entity_path(a.entity)
  end

  def destroy
    a = Alias.find(params[:id])
    a.destroy unless a.is_primary?
    redirect_to edit_entity_path(a.entity)
  end

  private

  def alias_params
    params.require(:alias)
      .permit(:name, :entity_id)
      .merge(last_user_id: current_user.sf_guard_user_id)
  end
end
