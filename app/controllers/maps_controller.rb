# frozen_string_literal: true

class MapsController < ApplicationController
  before_action :set_map, except: %i[new]
  before_action :authenticate_user!, :admins_only, only: [:feature]
  rescue_from ActiveRecord::RecordNotFound, with: :map_not_found
  rescue_from Exceptions::PermissionError, with: :map_not_found

  def embedded
    redirect_to(embedded_oligrapher_url(@map))
  end

  def show
    redirect_to(oligrapher_url(@map))
  end

  def raw
    # old map page for iframe embeds, forward to new embed page
    redirect_to embedded_map_url(@map)
  end

  def new
    redirect_to new_oligrapher_url
  end

  # POST /maps/:id/feature
  # Two possible actions: { map: { feature_action: 'ADD' } | { feature_action: 'REMOVE' } }
  def feature
    # private maps cannot be featured
    return head :bad_request if @map.is_private

    case params.require(:map)[:feature_action]&.upcase
    when 'ADD'
      @map.update_columns(is_featured: true)
    when 'REMOVE'
      @map.update_columns(is_featured: false)
    else
      return head :bad_request
    end
    redirect_back fallback_location: all_maps_path
  end

  private

  def set_map
    @map = NetworkMap.public_scope.find(params[:id])
  end
end
