class Group < ActiveRecord::Base
	belongs_to :campaign, inverse_of: :groups
	belongs_to :default_network, class_name: "List", inverse_of: :groups
	has_many :users, through: :group_users, inverse_of: :groups
	has_and_belongs_to_many :lists, join_table: "group_lists"
	has_many :entities, through: :lists, inverse_of: :groups

	mount_uploader :logo, GroupLogoUploader

	validates_presence_of :name, :slug

	def to_param
		slug
	end
end
