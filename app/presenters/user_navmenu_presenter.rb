# frozen_string_literal: true

class UserNavmenuPresenter
  extend Forwardable
  def_delegators :@items, :each, :size
  def_delegator 'Rails.application.routes.url_helpers', :user_edits_path

  MENU_ITEMS = [
    ['Login', '/login'],
    ['Sign Up', '/join'],
    [
      'Explore', [['Maps', Rails.application.routes.url_helpers.featured_maps_path],
                  ['Lists', Rails.application.routes.url_helpers.lists_path(featured: true)],
                  ['Tags', Rails.application.routes.url_helpers.tags_path],
                  ['Edits', Rails.application.routes.url_helpers.edits_path]]
    ],
    [
      'Help', [['Toolkit', '/toolkit'],
               ['Help', '/help'],
               ['Report a bug', '/bug_report']]
    ],
    [
      'About', [['LittleSis', '/about'],
                ['Features',  '/features'],
                ['Our Team', '/team'],
                ['Blog', 'https://news.littlesis.org'],
                ['Data API', '/api'],
                ['Source Code', 'https://github.com/public-accountability/littlesis-rails'],
                ['Disclaimer', '/disclaimer'],
                ['Contact Us', '/contact'],
                ['Jobs', 'https://public-accountability.org/category/job/'],
                ['Donate', '/donate']]
    ],
    ['Blog', 'https://news.littlesis.org']
  ].freeze

  ADD_LINKS = ['Add', [['Entity', '/entities/new'],
                       ['List', '/lists/new'],
                       ['Map', '/maps/new']]].freeze

  def initialize(user = nil)
    @items = if user
               user_items(user)
             else
               MENU_ITEMS
             end
  end

  private

  def user_items(user)
    [
      user_links(user),
      MENU_ITEMS[2], # explore
      ADD_LINKS,
      MENU_ITEMS[3], # help
      MENU_ITEMS[4]  # about
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
end
