# frozen_string_literal: true

module Entities
  class RoutesController < ApplicationController
    # Take old-style URLs and redirect them to the entity's canonical URL
    def redirect_to_canonical
      entity = Entity.find(params.fetch(:id))
      redirect_to entity.slug
    end
  end
end
