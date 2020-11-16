# frozen_string_literal: true

class User < ApplicationRecord
  include UserEdits::ActiveUsers

  MINUTES_BEFORE_USER_CAN_EDIT = 10

  enum role: { user: 0, admin: 1, system: 2 }

  serialize :abilities, UserAbilities
  serialize :settings, UserSettings

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            user_name: true,
            on: [:create, :update]
  validates :default_network_id, presence: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable,
         :trackable

  # Core associations
  has_one :user_profile, inverse_of: :user, dependent: :destroy
  has_one :api_token, dependent: :destroy
  has_many :user_permissions, dependent: :destroy
  has_many :permission_passes, foreign_key: 'creator_id', inverse_of: :creator, dependent: :destroy

  # entities last edited by the user
  has_many :edited_entities, class_name: "Entity", foreign_key: "last_user_id", inverse_of: :last_user

  # profile image, needs to be reworked or removed
  has_one :image, inverse_of: :user, dependent: :destroy

  # Maps and lists the user has created
  has_many :network_maps, inverse_of: :user
  has_many :lists, foreign_key: 'creator_user_id', inverse_of: :user

  # Requests made
  has_many :user_requests, inverse_of: :user, dependent: :destroy
  has_many :reviewed_requests,
           class_name: 'UserRequest', foreign_key: 'reviewer_id', inverse_of: :reviewer

  accepts_nested_attributes_for :user_profile

  before_validation :set_default_network_id

  delegate :name_first, :name_last, :full_name, to: :user_profile
  delegate(*UserAbilities::ABILITY_MAPPING.values, to: 'abilities')
  alias importer? bulker?

  def to_param
    username
  end

  def restricted?
    is_restricted
  end

  def can_edit?
    !restricted? && confirmed? && (MINUTES_BEFORE_USER_CAN_EDIT.minutes.ago > confirmed_at)
  end

  def raise_unless_can_edit!
    raise Exceptions::UserCannotEditError unless can_edit?
  end

  def image_url(type = nil)
    return ApplicationController.helpers.image_url('system/anon.png') if image.nil?

    type = (image.has_square ? 'square' : 'profile') if type.nil?
    image.image_path(type)
  end
  alias image_path image_url

  def url
    Rails.application.routes.url_helpers.user_page_path(self)
  end

  ###############
  # User Edits  #
  ###############

  def recent_edits(page = 1)
    UserEdits::Edits.new(self, page: page)
  end

  def edited_entities(page = 1)
    UserEdits::Edits.new(self, page: page, per_page: 10).edited_entities
  end

  ###############
  # Abilities   #
  ###############

  # creates 4 methods: add_ability, add_ability!, remove_ability, remove_ability!
  %i[add remove].each do |method|
    define_method("#{method}_ability") do |*args|
      self[:abilities] = abilities.public_send(method, *args)
      save
    end

    define_method("#{method}_ability!") do |*args|
      self[:abilities] = abilities.public_send(method, *args)
      save!
    end
  end

  ###############
  # Permissions #
  ###############

  def list_of_abilities
    abilities.to_a.join(", ")
  end

  def has_ability?(name) # rubocop:disable Naming/PredicateName, Metrics/MethodLength
    case name
    when :admin, 'admin'
      abilities.admin? || role == 'admin'
    when :edit, 'edit', 'editor', 'contributor'
      abilities.editor?
    when :delete, 'delete', 'deleter'
      abilities.deleter?
    when :merge, 'merge', 'merger'
      abilities.merger?
    when :list, 'list', 'lister'
      abilities.lister?
    when :bulk, 'bulk', 'bulker', 'importer'
      abilities.bulker?
    else
      Rails.logger.debug "User#has_ability? called with unknown permission: #{name}"
      false
    end
  end

  def create_default_permissions
    add_ability!(:edit) unless has_ability?(:edit)
  end

  def permissions
    @permissions ||= Permissions.new(self)
  end

  # String | nil --> Arel::Nodes::Grouping | nil
  # Creates sql like statement with arel, which searches
  # the username and email columns to find matching users.
  # Used by UsersController#admin
  def self.matches_username_or_email(query)
    return if query.nil?

    query_string = "%#{sanitize_sql_like(query)}%"
    arel_table[:username].matches(query_string).or(arel_table[:email].matches(query_string))
  end

  # Returns the user id from a range
  # of types: User, Integer, String
  # Used by LsHash
  def self.derive_last_user_id_from(input, allow_invalid: false)
    case input
    when String
      input.to_i
    when Integer
      input
    when User
      input.id
    else
      if allow_invalid
        APP_CONFIG['system_user_id']
      else
        raise TypeError, "Invalid class. Provided: #{input.class}"
      end
    end
  end

  def self.system_user
    return @_system_user if defined?(@_system_user)

    @_system_user = User.find(APP_CONFIG['system_user_id'])
  end

  def self.system_users
    Rails.cache.fetch('user/system_users', expires_in: 12.hours) do
      User.where(role: :system).to_a
    end
  end

  # Checks if name meets the character restrictions and
  # is case-insensitively unique. Also see `UserNameValidator`
  # String ---> Boolean
  def self.valid_username?(name)
    UserNameValidator.valid?(name) && !exists?(username: name)
  end

  private

  def set_default_network_id
    self.default_network_id = APP_CONFIG.fetch('default_network_id', 79) if default_network_id.nil?
  end
end
