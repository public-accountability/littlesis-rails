# frozen_string_literal: true

module Entities
  class AddRelationshipController < ApplicationController
    # Turbo Frame: /entities/add_relationship/search
    def search
      @results = EntitySearchService.new(query: params[:q], populate: true).results

      if @results.length.zero?
        render partial: 'entities/add_relationship/no_results'
      else
        render partial: 'entities/add_relationship/results'
      end
    end

    # Turbo Frame: /entities/add_relationship/new
    def new
      @entity1 = Entity.find(params[:entity1_id])
      @entity2 = Entity.find(params[:entity2_id])
      render partial: 'entities/add_relationship/new'
    end

    # Turbo Frame: /entities/add_relationship/new_entity
    def new_entity
      @entity1 = Entity.find(params[:entity1_id])
      @entity2 = Entity.new(name: params[:entity2_name].presence)
      render partial: 'entities/add_relationship/new_entity', locals: { related_entity: @entity1, entity: @entity2 }
    end
  end
end
