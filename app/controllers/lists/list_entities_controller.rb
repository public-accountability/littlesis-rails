# frozen_string_literal: true

module Lists
  # Handles adding/removing existing entities to and from lists
  class ListEntitiesController < ApplicationController
    include ListPermissions

    before_action :set_list
    before_action :set_permissions
    before_action -> { check_access(:editable) }
    before_action :authenticate_user!
    before_action :block_restricted_user_access

    def create
      raise Exceptions::PermissionError unless @list.user_can_edit?(current_user)

      ListEntity.find_or_initialize_by(list: @list, entity_id: params[:entity_id]).tap do |le|
        le.current_user = current_user
        le.save!
      end

      redirect_to members_list_path(@list)
    end

    def destroy
      ListEntity.find(params[:id]).tap do |le|
        le.current_user = current_user
        le.destroy!
      end

      redirect_to members_list_path(@list)
    end

    private

    def set_list
      @list = List.find(params[:list_id])
    end
  end
end
