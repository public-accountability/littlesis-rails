# frozen_string_literal: true

class UserDashboardPresenter < SimpleDelegator
  attr_reader :maps, :lists, :recent_updates

  def initialize(user)
    super(user)

    maps_init
    lists_init
    recent_updates_init
  end

  private

  def maps_init
  end

  def lists_init
  end

  def recent_updates_init
  end
end
