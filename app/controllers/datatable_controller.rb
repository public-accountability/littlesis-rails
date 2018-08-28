# frozen_string_literal: true

class DatatableController < ApplicationController
  before_action :set_entity, only: [:entity]

  def entity
    render json: RelationshipsDatatable.new(@entity).data
  end
end
