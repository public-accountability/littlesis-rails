# frozen_string_literal: true

class EditsController < ApplicationController
  before_action :authenticate_user!, :current_user_can_edit?
  before_action :set_page, only: [:index, :entity]
  before_action :set_entity, only: [:entity]

  def index
    @without_system_users = true
    @without_system_users = false if params[:without_system_users]&.downcase == 'false'
  end

  def entity
  end
end
