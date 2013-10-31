class Campaign < ActiveRecord::Base
	has_many :groups, inverse_of: :campaign
	
	mount_uploader :logo, CampaignLogoUploader
	mount_uploader :cover, CampaignCoverUploader
end
