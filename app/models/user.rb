class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :legacy_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  belongs_to :sf_guard_user, inverse_of: :user
  delegate :sf_guard_user_profile, to: :sf_guard_user, allow_nil: true
  delegate :public_name, to: :sf_guard_user_profile, allow_nil: true
  delegate :s3_url, to: :sf_guard_user_profile, allow_nil: true

  belongs_to :default_network, class_name: "List"
  belongs_to :sf_guard_user_profile, inverse_of: :user

  has_many :group_users, inverse_of: :user, dependent: :destroy
  has_many :groups, through: :group_users, inverse_of: :users

  has_many :note_users, inverse_of: :user, dependent: :destroy
  has_many :received_notes, class_name: "Note", through: :note_users, inverse_of: :recipients

  validates_uniqueness_of :sf_guard_user_id

  def self.create_all_from_profiles
  	SfGuardUserProfile.all.each do |p| 
  		p.create_user_with_email_password
  	end
  end

  def legacy_permissions
  	sf_gaurd_user.permissions
  end

  def has_legacy_permission(name)
  	sf_guard_user.has_permission(name)
  end

  def in_group?(group)
  	GroupUser.where(group_id: group, user_id: id).count > 0
  end

  def admin_in_group?(group)
  	GroupUser.where(group_id: group, user_id: id, is_admin: true).count > 0
  end
end
