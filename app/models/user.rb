# frozen_string_literal: true

class User < ApplicationRecord
  include UserEdits::ActiveUsers

  MINUTES_BEFORE_USER_CAN_EDIT = 60

  ROLES = {
    user: 0, # default
    admin: 1,
    system: 2,
    restricted: 3,
    editor: 4,
    collaborator: 5,
    deleted: 6
  }.freeze

  enum :role, ROLES, default: :user
  serialize :abilities, coder: UserAbilities, type: UserAbilities
  serialize :settings, coder: UserSettings, type: UserSettings

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            user_name: true,
            on: [:create, :update]

  # Include default devise modules. Others available are:
  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable
         # :lockable

  has_paper_trail only: %i[username about_me], on: %i[update], versions: { class_name: 'ApplicationVersion' }

  # Core associations
  has_one :user_profile, inverse_of: :user, required: false
  has_one :api_token, dependent: :destroy
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
  delegate :name, to: :user_profile

  def to_param
    username
  end

  # @return [User::Role]
  def role
    Role[super]
  end

  def admin?
    role.name == 'admin'
  end

  def restricted?
    is_restricted || role.name == 'restricted'
  end

  def deleted?
    role.name == 'deleted'
  end

  def system_account?
    role.name == 'system'
  end

  def active_for_authentication?
    super && role.include?(:login)
  end

  # Checks if user can make edits to database
  def can_edit?
    role.include? :edit_database
  end

  alias editor? can_edit?

  def raise_unless_can_edit!
    raise Exceptions::UserCannotEditError unless can_edit?
  end

  def leagcy_can_edit?
    !restricted? && confirmed? && (MINUTES_BEFORE_USER_CAN_EDIT.minutes.ago > confirmed_at)
  end

  def image_url(type = 'profile')
    return ApplicationController.helpers.image_url('system/anon.png') if image.nil?

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

  def edited_entities(page = 1, per_page: 10)
    UserEdits::Edits.new(self, page: page, per_page: per_page).edited_entities
  end

  def show_add_bulk_button?
    role.include?(:bulk_upload) || (created_at < 2.weeks.ago && sign_in_count > 2)
  end

  # String | nil --> Arel::Nodes::Grouping | nil
  # Creates sql like statement with arel, which searches
  # the username and email columns to find matching users.
  # Used by UsersController#admin
  def self.matches_username_or_email(query)
    return if query.blank?

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
        system_user_id
      else
        raise TypeError, "Invalid class. Provided: #{input.class}"
      end
    end
  end

  def self.system_user_id
    Rails.application.config.littlesis.fetch(:system_user_id)
  end

  def self.system_user
    return @_system_user if defined?(@_system_user)

    @_system_user = User.find(system_user_id)
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
    UserNameValidator.valid?(name) && !where('LOWER(username) = ?', name.downcase).exists?
  end
end
