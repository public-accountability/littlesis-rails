class Campaign < ActiveRecord::Base
	include Cacheable

	has_many :groups, inverse_of: :campaign
	has_many :users, through: :groups, inverse_of: :campaigns
	has_many :edited_entities, class_name: "Entity", through: :users
	has_many :entities, through: :groups, inverse_of: :campaigns

	mount_uploader :logo, CampaignLogoUploader
	mount_uploader :cover, CampaignCoverUploader

	validates_presence_of :name, :slug

	def to_param
		slug
	end

	def featured_entities
		Entity.joins(lists: :groups).where("group_lists.is_featured = ?", true).where("groups.campaign_id = ?", id)
	end

	def sf_guard_user_ids
		User.joins(:groups).where("groups.campaign_id = ?", id).pluck(:sf_guard_user_id)
	end
end
