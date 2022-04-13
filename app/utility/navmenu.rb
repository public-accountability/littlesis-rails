# frozen_string_literal: true

class Navmenu
  extend Forwardable
  def_delegator 'I18n', :t
  def_delegator 'Rails.application.routes.url_helpers', :user_edits_path
  def_delegator :@menu, :each, :size

  attr_reader :menu

  # @param user [User]
  # @return [Array]
  def self.for(user)
    new(user).menu
  end

  # @param user [User, Nil] User
  def initialize(user)
    @user = user
    @menu = [
      user_menu,
      explore_menu,
      add_menu,
      about_menu,
      features_menu
    ].compact.freeze
  end

  def user_menu
    if @user.present?
      [
        @user.username, [
          [t('littlesis.map').pluralize.capitalize, '/home/maps'],
          [t('vocab.lists').capitalize, '/home/lists'],
          (@user.editor? ? [t('vocab.edits').capitalize, user_edits_path(username: @user.username)] : nil),
          :divider,
          (@user.admin? ? ['Admin', '/admin'] : nil),
          [t('vocab.settings').capitalize, '/settings'],
          [t('vocab.logout').titleize, '/logout']
        ].compact
      ]
    else
      [t('vocab.login').titleize, '/login']
    end
  end

  def about_menu
    [t('vocab.about').capitalize,
     [
       ['LittleSis', '/about'],
       (@user.nil? ? [t('vocab.signup').titleize, '/join'] : nil),
       [t('vocab.help').capitalize, '/help'],
       ['API', '/api'],
       [t('vocab.disclaimer'), '/disclaimer'],
       [t('phrases.contact_us').titleize, '/contact'],
       [t('vocab.donate').capitalize, '/donate']
     ].compact
    ]
  end

  def add_menu
    if @user.present? && !@user.restricted?
      [t('vocab.add').capitalize,
       [
         (@user.editor? ? [t('littlesis.entity').capitalize, '/entities/new'] : nil),
         (@user.role.include?(:create_list) ? [t('littlesis.list').capitalize, '/lists/new'] : nil),
         (@user.role.include?(:create_map) ? [t('littlesis.map').capitalize, '/maps/new'] : nil)
       ].compact
      ]
    end
  end

  def explore_menu
    [
      t('vocab.explore').capitalize,
      [
        [t('littlesis.map').pluralize.capitalize, '/oligrapher'],
        [t('littlesis.list').pluralize.capitalize, '/lists?featured=true'],
        [t('littlesis.tag').pluralize.capitalize, '/tags'],
        (@user&.editor? ? [t('vocab.edits').capitalize, '/edits'] : nil),
        (@user&.role&.include?(:datasets) ? [t('littlesis.datasets').titleize, '/datasets'] : nil)
      ].compact
    ]
  end

  def features_menu
    [t('vocab.features').capitalize,
     [['Blog', 'https://news.littlesis.org'],
      [t('vocab.toolkit').capitalize, '/toolkit'],
      ['Powerlines', 'https://powerlines101.org']]]
  end
end
