# frozen_string_literal: true

class EditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: [:index, :entity]
  before_action :set_entity, only: [:entity]

  def index
  end

  def entity
  end
end
