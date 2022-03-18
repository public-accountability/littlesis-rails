# frozen_string_literal: true

module Lists
  # Handles creation of entities in the context of lists
  class EntitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :current_user_can_edit?
    before_action :set_list, :set_entity

    def create
      if @entity.save
        # Ought to be able to do this stuff with accepts_nested_attributes_for
        add_extensions
        add_to_list
        notice = "#{@entity.name} added to #{@list.name} list"
      else
        notice = "Could not save entity: #{@entity.errors.full_messages.join('. ')}"
      end

      redirect_to members_list_path(@list), notice: notice
    end

    private

    def add_extensions
      params[:types].each { |type| @entity.add_extension(type) } if params[:types].present?
    end

    def add_to_list
      raise Exceptions::PermissionError unless @list.user_can_edit?(current_user)

      ListEntity.find_or_initialize_by(list: @list, entity: @entity).tap do |le|
        le.current_user = current_user
        le.save!
      end
    end

    def set_list
      @list = List.find(params[:list_id])
    end

    def set_entity
      @entity = Entity.new(new_entity_params)
    end

    def new_entity_params
      Utility.nilify_blank_vals(
        params
        .require(:entity)
        .permit(:name, :blurb, :primary_ext)
        .to_h
        .merge(last_user_id: User.derive_last_user_id_from(current_user))
      ).with_indifferent_access
    end
  end
end
