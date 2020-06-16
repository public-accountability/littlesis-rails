# frozen_string_literal: true

class ExternalRelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_relationship, only: [:show]

  def show
  end

  def random
    redirect_to action: :show,
                id: ExternalRelationship.unmatched.order('RAND()').limit(1).pluck(:id).first
  end

  private

  def set_external_relationship
    @external_relationship = ExternalRelationship.find(params.require(:id)).presenter
  end
end
