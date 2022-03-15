# frozen_string_literal: true

class UserNavmenuPresenter
  attr_reader :items

  class << self
    delegate :t, to: 'I18n'
  end

  delegate :each, :size, to: :@items

  private_class_method def self.create_menus
    {
      about: [t('vocab.about').capitalize,
              [['LittleSis', '/about'],
               [t('vocab.signup').titleize, '/join'],
               [t('vocab.help').capitalize, '/help'],
               ['API', '/api'],
               [t('vocab.disclaimer'), '/disclaimer'],
               [t('phrases.contact_us').titleize, '/contact'],
               [t('vocab.donate').capitalize, '/donate']]],

      add: [t('vocab.add').capitalize,
            [[t('littlesis.entity').capitalize, '/entities/new'],
             [t('littlesis.list').capitalize, '/lists/new'],
             [t('littlesis.map').capitalize, '/maps/new']]],

      explore: [t('vocab.explore').capitalize,
                [[t('littlesis.map').pluralize.capitalize, '/oligrapher'],
                 [t('littlesis.list').pluralize.capitalize, '/lists?featured=true'],
                 [t('littlesis.tag').pluralize.capitalize, '/tags']]],

      features: [t('vocab.features').capitalize,
                 [['Blog', 'https://news.littlesis.org'],
                  [t('vocab.toolkit').capitalize, '/toolkit'],
                  ['Powerlines', 'https://powerlines101.org']]]

    }.tap do |h|
      h[:default] = [[t('vocab.login').titleize, '/login'], h[:explore], h[:about], h[:features]]
      h[:user_explore] = h[:explore].clone
      h[:user_explore][1] << [t('vocab.edits').capitalize, '/edits']
      h[:admin_explore] = h[:user_explore].clone
      h[:admin_explore][1] << [t('littlesis.datasets').titleize, '/datasets']
    end
  end

  MENUS = {
    en: I18n.with_locale(:en) { create_menus }.freeze,
    es: I18n.with_locale(:es) { create_menus }.freeze
  }.freeze

  def initialize(user = nil)
    @items = if user
               user_items(user)
             else
               MENUS.dig(I18n.locale, :default)
             end
  end

  private

  def user_items(user)
    [
      user_links(user),
      (user.admin? ? MENUS.dig(I18n.locale, :admin_explore) : MENUS.dig(I18n.locale, :user_explore)),
      MENUS.dig(I18n.locale, :add),
      MENUS.dig(I18n.locale, :about),
      MENUS.dig(I18n.locale, :features)
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
