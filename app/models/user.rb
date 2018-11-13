# frozen_string_literal: true

class User < ApplicationRecord
  include UserEdits

  MINUTES_BEFORE_USER_CAN_EDIT = 10

  validates :sf_guard_user_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, user_name: true, on: :create
  validates :default_network_id, presence: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable :legacy_authenticatable
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable

  # after_database_authentication :set_sf_session
  # Setup accessible (or protected) attributes for your model
  #  attr_accessible :email, :password, :password_confirmation, :remember_me

  belongs_to :sf_guard_user, inverse_of: :user

  has_one :user_profile, inverse_of: :user, dependent: :destroy
  has_one :image, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :sf_guard_user

  before_validation :set_default_network_id

  delegate :name_first, :name_last, :full_name, to: :user_profile

  has_many :edited_entities, class_name: 'Entity', foreign_key: 'last_user_id', primary_key: 'sf_guard_user_id'

  has_many :group_users, inverse_of: :user, dependent: :destroy
  has_many :groups, through: :group_users, inverse_of: :users
  has_many :campaigns, through: :groups, inverse_of: :users

  has_many :network_maps, primary_key: 'sf_guard_user_id', inverse_of: :user

  has_many :lists, foreign_key: 'creator_user_id', inverse_of: :user

  has_one :api_token, dependent: :destroy
  has_many :user_permissions, dependent: :destroy

  has_many :user_requests, inverse_of: :user, dependent: :destroy
  has_many :reviewed_requests, class_name: "UserRequest", foreign_key: 'reviewer_id', inverse_of: :reviewer

  def image_path
    "https://#{APP_CONFIG['asset_host']}/images/system/anon.png"
  end
  alias image_url image_path

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

  # Groups #

  def in_group?(group)
    GroupUser.where(group_id: group.id, user_id: id).count > 0
  end

  def admin_in_group?(group)
    GroupUser.where(group_id: group.id, user_id: id, is_admin: true).count > 0
  end

  def in_campaign?(campaign)
    GroupUser.joins(:group).where("groups.campaign_id" => campaign.id, user_id: id).count > 0
  end

  def legacy_created_at
    return created_at if sf_guard_user.nil?

    sf_guard_user.created_at
  end

  def legacy_url
    "/user/#{username}"
  end

  def full_legacy_url
    "https://littlesis.org/#{legacy_url}"
  end

  def legacy_check_password(password)
    Digest::SHA1.hexdigest(sf_guard_user.salt + password) == sf_guard_user.password
  end

  def image_url
    return '/images/system/anon.png' if image.nil?

    type = (image.has_square ? 'square' : 'profile') if type.nil?
    image.image_path(type)
  end

  def recent_edits(page = 1)
    Edits.new(self, page: page)
  end

  ###############
  # Permissions #
  ###############

  def legacy_permissions
    sf_guard_user.permissions
  end

  def has_legacy_permission(name)
    sf_guard_user.has_permission(name)
  end

  def admin?
    has_legacy_permission 'admin'
  end

  def importer?
    has_legacy_permission 'importer'
  end

  def bulker?
    has_legacy_permission 'bulker'
  end

  def merger?
    has_legacy_permission 'merger'
  end

  def create_default_permissions
    unless has_legacy_permission('contributor')
      SfGuardUserPermission.create(permission_id: 2, user_id: sf_guard_user.id)
    end
    unless has_legacy_permission('editor')
      SfGuardUserPermission.create(permission_id: 3, user_id: sf_guard_user.id)
    end
  end

  def permissions
    @permissions ||= Permissions.new(self)
  end

  def create_chat_account
    return :existing_account if chatid.present?
    Chat.create_user(self)
  end

  # Returns the sf_guard_user_id from a range
  # of types: User, SfGuardUser, Integer, String
  # Used by LsHash
  def self.derive_last_user_id_from(input, allow_invalid: false)
    case input
    when String
      input.to_i
    when Integer
      input
    when User
      input.sf_guard_user_id
    when SfGuardUser
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

  # Checks if name meets the character restrictions and
  # is case-insensitively unique. Also see `UserNameValidator`
  # String ---> Boolean
  def self.valid_username?(name)
    UserNameValidator.valid?(name) && !exists?(username: name)
  end

  private

  def set_default_network_id
    self.default_network_id = APP_CONFIG['default_network_id'] if self.default_network_id.nil?
  end
end
