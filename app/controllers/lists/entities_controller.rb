# frozen_string_literal: true

module Lists
  class EntitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :block_restricted_user_access
    before_action -> { current_user.raise_unless_can_edit! }
    before_action :set_list, :set_entity

    def create
      if @entity.save
        # Ought to be able to do this stuff with accepts_nested_attributes_for
        add_extensions
        add_to_list
        flash[:success] = 'Entity added to list'
      else
        flash[:alert] = 'Could not save entity'
      end

      redirect_to members_list_path(@list)
    end

    private

    def add_extensions
      params[:types].each { |type| @entity.add_extension(type) } if params[:types].present?
    end

    def add_to_list
      ListEntity.add_to_list!(
        list_id: @list.id,
        entity_id: @entity.id,
        current_user: current_user
      )
    end

    def set_list
      @list = List.find(params[:list_id])
    end

    def set_entity
      @entity = Entity.new(new_entity_params)
    end

    def new_entity_params
      LsHash.new(params.require(:entity).permit(:name, :blurb, :primary_ext).to_h)
        .with_last_user(current_user)
        .nilify_blank_vals
    end
  end
end
