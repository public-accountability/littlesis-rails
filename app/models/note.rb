
class Note < ActiveRecord::Base
  include SingularTable

	has_many :note_recipients, class_name: "NoteUser", inverse_of: :note, dependent: :destroy
	has_many :recipients, through: :note_recipients, source: :user, inverse_of: :received_notes

	has_many :note_entities, inverse_of: :note, dependent: :destroy
	has_many :entities, through: :note_entities, inverse_of: :notes

	has_many :note_relationships, inverse_of: :note, dependent: :destroy
	has_many :relationships, through: :note_relationships, inverse_of: :notes

	has_many :note_lists, inverse_of: :note, dependent: :destroy
	has_many :lists, through: :note_lists, inverse_of: :notes

	has_many :note_networks, inverse_of: :note, dependent: :destroy
	has_many :networks, class_name: "List", through: :note_networks, inverse_of: :network_notes

	has_many :note_groups, inverse_of: :note, dependent: :destroy
	has_many :groups, through: :note_groups, inverse_of: :notes

	# before_save :parse

	def sf_guard_user
		SfGuardUser.find(user_id)
	end

	def user
		legacy? ? sf_guard_user.user : User.find(user_id)
	end

	def normalize
		self.recipients = User.where(sf_guard_user_id: self.class.commas_to_array(alerted_user_ids))
		self.entities = Entity.unscoped.find(self.class.commas_to_array(read_attribute(:entity_ids)))
		self.relationships = Relationship.unscoped.find(self.class.commas_to_array(read_attribute(:relationship_ids)))
		self.lists = List.unscoped.find(self.class.commas_to_array(lslist_ids))
		self.groups = Group.joins(:sf_guard_group).where(id: self.class.commas_to_array(sfguardgroup_ids))
		self.networks = List.unscoped.find(self.class.commas_to_array(read_attribute(:network_ids)))
		self
	end

	def self.commas_to_array(str)
		return [] if str.blank?
		str.chomp(",").reverse.chomp(",").reverse.split(",")
	end

	def self.username_chars
		"a-zA-Z0-9."
	end

	def parse
		matches = body_raw.scan /@([#{self.class.username_chars}]+)(?!([a-zA-Z0-9]|:\d))/i
		usernames = matches.map(&:first)
		self.recipients = User.where(username: usernames)

		matches = body_raw.scan /@entity:(\d+)/i
		entity_ids = matches.map(&:first)
		self.entities = Entity.find(entity_ids)

		matches = body_raw.scan /@rel:(\d+)/i
		rel_ids = matches.map(&:first)
		self.relationships = Relationship.find(rel_ids)

		matches = body_raw.scan /@list:(\d+)/i
		list_ids = matches.map(&:first)
		self.lists = List.find(list_ids)

		matches = body_raw.scan /@group:(\d+)/i
		group_ids = matches.map(&:first)
		groups = legacy? ? Group.joins(:sf_guard_group).where("sf_guard_group.id" => group_ids) : Group.find(group_ids)

		matches = body_raw.scan /@group:([#{self.class.username_chars}]+)/i
		group_slugs = matches.map(&:first)
		self.groups = groups + Group.where(slug: group_slugs)
	end

	def legacy?
		is_legacy
	end
end
