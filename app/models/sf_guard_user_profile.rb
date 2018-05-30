class SfGuardUserProfile < ApplicationRecord
  include SingularTable	
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name_first, presence: true
  validates :home_network_id, presence: true
  validates :reason, signup_reason: true
  validates_uniqueness_of :public_name

  belongs_to :sf_guard_user, inverse_of: :sf_guard_user_profile, foreign_key: "user_id"
  belongs_to :user, foreign_key: "user_id", primary_key: "sf_guard_user_id", inverse_of: :sf_guard_user_profile

  # this is used by rake task: create_all_from_profiles
  # After the new sign up system, it's no longer needed
  # (ziggy 10-27-16)
  # def create_user_with_email_password
  # 	User.where(sf_guard_user_id: user_id).first_or_create do |user|
  #       		user.username = public_name
  #       		user.email = email
  #     # disabled until devise :database_authenticatable is used
  #       		# user.password = email
  #       		# user.password_confirmation = email
  #       		user.sf_guard_user_id = user_id
  #       		user.default_network_id = home_network_id
  #       	end
  #       end

  def full_name
    (name_first + " " + name_last).chomp
  end

  # def image_url(type)
  #   return ActionController::Base.helpers.asset_path("images/system/user.png") if filename.nil?
  #   image_path(type)
  # end

  def image_path(type = nil)
    "https://#{APP_CONFIG['asset_host']}/images/system/anon.png"
    # return ActionController::Base.helpers.asset_path("images/system/user.png") if filename.nil?
    # ActionController::Base.helpers.asset_path("images/#{type}/#{filename(type)}")
  end

  def filename(type=nil)
    return read_attribute(:filename) unless type == "square"
    fn = read_attribute(:filename)
    fn.chomp(File.extname(fn)) + '.jpg'
  end

  def self.without_user
    joins("LEFT JOIN users ON users.sf_guard_user_id = sf_guard_user_profile.user_id").where("users.id IS NULL")
  end
end
