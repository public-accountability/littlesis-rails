# frozen_string_literal: true

class UserDashboardPresenter
  attr_reader :user, :maps, :lists, :recent_updates

  DASHBOARD_MAPS_PER_PAGE = 18
  DASHBOARD_LISTS_PER_PAGE = 10

  def initialize(user, map_page: nil, list_page: nil)
    @user = user
    @map_page = map_page&.to_i || 1
    @list_page = list_page&.to_i || 1

    maps_init
    lists_init
    recent_updates_init
    freeze
  end

  def show_list_section?
    @lists.present?
  end

  private

  def maps_init
    @maps = @user
              .network_maps
              .order(id: :desc)
              .page(@map_page)
              .per(DASHBOARD_MAPS_PER_PAGE)
  end

  def lists_init
    @lists = @user
               .lists
               .order(id: :desc)
               .page(@list_page)
               .per(DASHBOARD_LISTS_PER_PAGE)
  end

  def recent_updates_init
    @recent_updates = @user.edited_entities
  end
end
