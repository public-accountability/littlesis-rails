class Campaign < ActiveRecord::Base
	has_many :groups, inverse_of: :campaign

	mount_uploader :logo, CampaignLogoUploader
	mount_uploader :cover, CampaignCoverUploader

	validates_presence_of :name, :slug

	def to_param
		slug
	end
end
