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

    def update
      if data = params[:data]
        list_entity = ListEntity.find(data[:list_entity_id])
        list_entity.rank = data[:rank]
        if list_entity.list.custom_field_name.present?
          list_entity.custom_field = (data[:context].presence)
        end
        list_entity.save
        list_entity.list.clear_cache(request.host)
        table = ListDatatable.new(@list)
        render json: { row: table.list_entity_data(list_entity, data[:interlock_ids],
                                                   data[:list_interlock_ids]) }
      else
        render json: {}, status: :not_found
      end
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
