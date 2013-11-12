class Group < ActiveRecord::Base
	include Bootsy::Container

	belongs_to :campaign, inverse_of: :groups
	
	belongs_to :default_network, class_name: "List", inverse_of: :groups
	
	has_many :group_users, inverse_of: :group, dependent: :destroy
	has_many :users, through: :group_users, inverse_of: :groups
	
	has_many :group_lists, inverse_of: :group, dependent: :destroy
	has_many :lists, through: :group_lists, inverse_of: :groups
	
	has_many :entities, through: :lists, inverse_of: :groups

	has_many :note_groups, inverse_of: :group, dependent: :destroy
	has_many :notes, through: :note_groups, inverse_of: :groups

	mount_uploader :logo, GroupLogoUploader
	mount_uploader :cover, GroupCoverUploader

	validates_presence_of :name, :slug

	def to_param
		slug
	end

	def featured_lists
		lists.where("group_lists.is_featured = ?", true)
	end

	def featured_entities
		entities.where("group_lists.is_featured = ?", true)
	end

	def guard_user_ids
		SfGuardUser.joins(user: :groups).where("groups.id" => id).pluck(:id)
	end
end
