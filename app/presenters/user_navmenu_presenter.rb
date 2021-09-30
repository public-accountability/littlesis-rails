# frozen_string_literal: true

class UserNavmenuPresenter
  extend Forwardable
  def_delegators :@items, :each, :size
  def_delegator 'Rails.application.routes.url_helpers', :user_edits_path

  # other pages:
  # ['Source Code', 'https://github.com/public-accountability/littlesis-rails']
  # ['Bulk Data', '/bulk_dafta']
  # ['Toolkit', '/toolkit']
  # ['Report a bug', '/bug_report']

  ABOUT_MENU = ['About', [['LittleSis', '/about'],
                          ['Sign Up', '/join'],
                          ['Help', '/help'],
                          ['API', '/api'],
                          ['Disclaimer', '/disclaimer'],
                          ['Contact Us', '/contact'],
                          ['Donate', '/donate']]].freeze

  USER_ABOUT_MENU = ['About', [['LittleSis', '/about'],
                               ['Blog', 'https://news.littlesis.org'],
                               ['Help', '/help'],
                               ['API', '/api'],
                               ['Disclaimer', '/disclaimer'],
                               ['Contact Us', '/contact'],
                               ['Donate', '/donate']]].freeze

  ADD_MENU = ['Add', [['Entity', '/entities/new'],
                      ['List', '/lists/new'],
                      ['Map', '/maps/new']]].freeze

  EXPLORE_MENU = ['Explore', [['Maps', Rails.application.routes.url_helpers.featured_maps_path],
                              ['Lists', Rails.application.routes.url_helpers.lists_path(featured: true)],
                              ['Tags', Rails.application.routes.url_helpers.tags_path]]].freeze

  USER_EXPLORE_MENU = ['Explore', [['Maps', Rails.application.routes.url_helpers.featured_maps_path],
                                   ['Lists', Rails.application.routes.url_helpers.lists_path(featured: true)],
                                   ['Tags', Rails.application.routes.url_helpers.tags_path],
                                   ['Edits', Rails.application.routes.url_helpers.edits_path]]].freeze

  ADMIN_EXPLORE_MENU = ['Explore', [['Maps', Rails.application.routes.url_helpers.featured_maps_path],
                                    ['Lists', Rails.application.routes.url_helpers.lists_path(featured: true)],
                                    ['Tags', Rails.application.routes.url_helpers.tags_path],
                                    ['Edits', Rails.application.routes.url_helpers.edits_path],
                                    ['Datasets', Rails.application.routes.url_helpers.datasets_path]]].freeze
  DEFAULT_MENU = [
    ['Login', '/login'],
    EXPLORE_MENU,
    ABOUT_MENU,
    ['Blog', 'https://news.littlesis.org']
  ].freeze

  def initialize(user = nil)
    @items = if user
               user_items(user)
             else
               DEFAULT_MENU
             end
  end

  private

  def user_items(user)
    [
      user_links(user),
      user_explore(user),
      ADD_MENU,
      USER_ABOUT_MENU
    ]
  end

  def user_links(user)
    [
      user.username, [
        ['Maps', '/home/maps'],
        ['Lists', '/home/lists'],
        ['Edits', user_edits_path(username: user.username)],
        :divider,
        (user.admin? ? ['Admin', '/admin'] : nil),
        ['Settings', '/users/edit'],
        ['Logout', '/logout']
      ].compact
    ]
  end

  def user_explore(user)
    if user.admin?
      ADMIN_EXPLORE_MENU
    else
      USER_EXPLORE_MENU
    end
  end
end
