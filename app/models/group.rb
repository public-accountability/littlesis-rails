class Group < ActiveRecord::Base
	belongs_to :default_network, class_name: "List", inverse_of: :groups
	belongs_to :sf_guard_group, foreign_key: "slug", primary_key: "name"
	
	has_many :group_users, inverse_of: :group, dependent: :destroy
	has_many :users, through: :group_users, inverse_of: :groups
	has_many :edited_entities, class_name: "Entity", through: :users
	
	has_many :group_lists, inverse_of: :group, dependent: :destroy
	has_many :lists, through: :group_lists, inverse_of: :groups
	
	has_many :entities, through: :lists, inverse_of: :groups

	mount_uploader :logo, GroupLogoUploader
	mount_uploader :cover, GroupCoverUploader

	scope :working, -> { joins(:sf_guard_group).where("sf_guard_group.is_working" => true) }
	scope :public_scope, -> { where(is_private: false) }

	validates_presence_of :name, :slug
	validates_uniqueness_of :name, :slug

	def to_param
		slug
	end

	def featured_lists
		lists.where("group_lists.is_featured = ?", true)
	end

	def featured_entities
		entities.where("group_lists.is_featured = ?", true)
	end

	def sf_guard_user_ids
		users.pluck(:sf_guard_user_id)		
	end

	def private?
		is_private
	end

	def convert_legacy_description		
		self.description =  HTMLEntities.new.decode(description)
	end
end
