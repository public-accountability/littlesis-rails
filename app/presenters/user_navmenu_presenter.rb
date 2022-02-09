# frozen_string_literal: true

class UserNavmenuPresenter
  attr_reader :items

  class << self
    delegate :tags_path, :lists_path, :edits_path, :datasets_path, :featured_maps_path, to: 'Rails.application.routes.url_helpers'
  end

  delegate :each, :size, to: :@items

  # other pages:
  # Source Code https://github.com/public-accountability/littlesis-rails
  # Bulk Data /bulk_data'
  # Toolkit /toolkit
  # Report a bug /bug_report
  # featured maps featured_maps_path

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

  EXPLORE_MENU = ['Explore', [['Maps', '/oligrapher'],
                              ['Lists', lists_path(featured: true)],
                              ['Tags', tags_path]]].freeze

  USER_EXPLORE_MENU = ['Explore', [['Maps', '/oligrapher'],
                                   ['Lists', lists_path(featured: true)],
                                   ['Tags', tags_path],
                                   ['Edits', edits_path]]].freeze

  ADMIN_EXPLORE_MENU = ['Explore', [['Maps', '/oligrapher'],
                                    ['Lists', lists_path(featured: true)],
                                    ['Tags', tags_path],
                                    ['Edits', edits_path],
                                    ['Datasets', datasets_path]]].freeze

  FEATURES_MENU = ['Features', [['Blog', 'https://news.littlesis.org'],
                                ['Toolkit', '/toolkit'],
                                ['Powerlines', 'https://powerlines101.org']]].freeze

  DEFAULT_MENU = [
    ['Login', '/login'],
    EXPLORE_MENU,
    ABOUT_MENU,
    FEATURES_MENU
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
      (user.admin? ? ADMIN_EXPLORE_MENU : USER_EXPLORE_MENU),
      ADD_MENU,
      USER_ABOUT_MENU
    ]
  end

  def user_links(user)
    [
      user.username, [
        ['Maps', '/home/maps'],
        ['Lists', '/home/lists'],
        ['Edits', Rails.application.routes.url_helpers.user_edits_path(username: user.username)],
        :divider,
        (user.admin? ? ['Admin', '/admin'] : nil),
        ['Settings', '/users/edit'],
        ['Logout', '/logout']
      ].compact
    ]
  end
end
