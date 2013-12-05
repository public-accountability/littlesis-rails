class SfGuardUserProfile < ActiveRecord::Base
  include SingularTable	

  belongs_to :sf_guard_user, inverse_of: :sf_guard_user_profile, foreign_key: "user_id"

  def create_user_with_email_password
  	User.where(sf_guard_user_id: user_id).first_or_create do |user|
			user.username = public_name
			user.email = email
      # disabled until devise :database_authenticatable is used
			# user.password = email
			# user.password_confirmation = email
			user.sf_guard_user_id = user_id
			user.default_network_id = home_network_id
		end
	end

	def full_name
		(name_first + " " + name_last).chomp
	end

  def s3_url(type)
  	return S3.url(ActionController::Base.helpers.asset_path("images/system/user.png")) if filename.nil?
    S3.url(image_path(type))
  end
        
  def image_path(type)
    ActionController::Base.helpers.asset_path("images/#{type}/#{filename(type)}")  
  end

  def filename(type=nil)
    return read_attribute(:filename) unless type == "square"
    fn = read_attribute(:filename) 
    fn.chomp(File.extname(fn)) + '.jpg'
  end
end