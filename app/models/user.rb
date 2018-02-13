class User < ApplicationRecord
  include ChatUser
  include UserEdits

  validates :sf_guard_user_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :default_network_id, presence: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # :legacy_authenticatable, 
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable

  # after_database_authentication :set_sf_session
  # Setup accessible (or protected) attributes for your model
  #  attr_accessible :email, :password, :password_confirmation, :remember_me

  belongs_to :sf_guard_user, inverse_of: :user
  has_one :sf_guard_user_profile, foreign_key: "user_id", primary_key: "sf_guard_user_id", inverse_of: :user
  has_one :image, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :sf_guard_user

  before_validation :set_default_network_id
  
  # delegate :sf_guard_user_profile, to: :sf_guard_user, allow_nil: true
  delegate :image_path, to: :sf_guard_user_profile, allow_nil: true

  has_many :edited_entities, class_name: "Entity", foreign_key: "last_user_id", primary_key: "sf_guard_user_id"

  alias :image_url :image_path

  belongs_to :default_network, class_name: "List"

  has_many :group_users, inverse_of: :user, dependent: :destroy
  has_many :groups, through: :group_users, inverse_of: :users
  has_many :campaigns, through: :groups, inverse_of: :users

  has_many :notes, foreign_key: "new_user_id", inverse_of: :user

  has_many :note_users, inverse_of: :user, dependent: :destroy
  has_many :received_notes, class_name: "Note", through: :note_users, source: :note, inverse_of: :recipients
  has_many :network_maps, primary_key: "sf_guard_user_id"

  has_many :lists, foreign_key: "creator_user_id", inverse_of: :user

  has_one :api_token
  has_many :user_permissions

  def to_param
    username
  end

  def restricted?
    is_restricted
  end

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

  def notes_with_replies
		Note.with_joins
	    .where("note.new_user_id = ? OR users.id = ?", id, id)
  end

  def notes_with_replies_visible_to_user(user)
  	return notes_with_replies.public if user.nil?
  	notes_with_replies.where("note.is_private = ? OR users.id = ?", false, user.id)
  end

  def notes_visible_to_user(user)
  	return notes.public.order("note.created_at DESC") if user.nil?
  	notes.with_joins
  		.where("note.is_private = ? OR users.id = ?", false, user.id)
  end

  def received_notes_visible_to_user(user)
  	return received_notes.public.order("note.created_at DESC") if user.nil?
  	received_notes.with_joins
  		.where("note.is_private = ? OR users.id = ?", false, user.id)
  end

  def show_full_name?
    sf_guard_user_profile.show_full_name
  end

  def full_name(override=false)
    return nil unless override or show_full_name?
    sf_guard_user_profile.full_name
  end

  def bio
    sf_guard_user_profile.bio
  end

  def legacy_url
    "/user/#{username}"
  end

  def full_legacy_url
    "//littlesis.org" + legacy_url
  end

  def legacy_check_password(password)
    Digest::SHA1.hexdigest(sf_guard_user.salt + password) == sf_guard_user.password
  end

  def image_url
    return "/images/system/anon.png" if image.nil?
    type = (image.has_square ? "square" : "profile") if type.nil?
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

  # Returns the sf_guard_user_id from a range
  # of types: User, SfGuardUser, Integer, String
  # Used by LsHash
  def self.derive_last_user_id_from(input)
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
      raise ArgumentError, "Invalid class. Provided: #{input.class}"
    end
  end

  private

  def set_default_network_id
    self.default_network_id = APP_CONFIG['default_network_id'] if self.default_network_id.nil?
  end
end
