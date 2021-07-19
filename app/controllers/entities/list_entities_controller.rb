# frozen_string_literal: true

module Entities
  # Handles adding of entities to lists
  class ListEntitiesController < ApplicationController
    include EntitiesHelper

    before_action :set_entity, :set_list
    before_action :authenticate_user!
    before_action -> { current_user.raise_unless_can_edit! }

    def create
      raise Exceptions::PermissionError unless @list.user_can_edit?(current_user)

      ListEntity.find_or_initialize_by(list: @list, entity_id: params[:entity_id]).tap do |le|
        le.current_user = current_user
        le.save!
      end

      flash[:notice] = "Added to list '#{@list.name}'"
      redirect_to concretize_entity_path(@entity)
    end

    private

    def entity_id
      params.select do |k|
        k =~ /entity_id|org_id|person_id/
      end.values.first
    end

    def set_entity
      @entity = Entity.unscoped.find(entity_id)
      raise Entity::EntityDeleted if @entity.is_deleted?
    end

    def set_list
      @list = List.find(params[:list_id])
    end
  end
end
