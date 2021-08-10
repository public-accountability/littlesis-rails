# frozen_string_literal: true

module Relationships
  class RoutesController < ApplicationController
    # Take old-style URLs and redirect them to the relationship's canonical URL
    def redirect_to_canonical
      redirect_to relationship_path(params.fetch(:id))
    end
  end
end
