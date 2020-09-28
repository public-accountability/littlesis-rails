# frozen_string_literal: true

class DatatableController < ApplicationController
  before_action :set_entity, only: [:entity]

  def entity
    set_cache_control(10.minutes)
    render json: cache_relationships_datatable
  end

  private

  def cache_relationships_datatable
    Rails.cache.fetch("relationships_datatable/#{@entity.cache_key_with_version}", expires_in: 2.days) do
      RelationshipsDatatable.new(@entity).data
    end
  end
end
