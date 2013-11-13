
class Note < ActiveRecord::Base
  include SingularTable

	belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :notes
	delegate :user, to: :sf_guard_user, allow_nil: true

	has_many :note_recipients, class_name: "NoteUser", inverse_of: :note, dependent: :destroy
	has_many :recipients, through: :note_recipients, source: :user, inverse_of: :received_notes

	has_many :note_entities, inverse_of: :note, dependent: :destroy
	has_many :entities, through: :note_entities, inverse_of: :notes

	has_many :note_relationships, inverse_of: :note, dependent: :destroy
	has_many :relationships, through: :note_relationships, inverse_of: :notes

	has_many :note_lists, inverse_of: :note, dependent: :destroy
	has_many :lists, -> { where(is_network: false) }, through: :note_lists, inverse_of: :notes
	has_many :networks, -> { where(is_network: true) }, through: :note_lists, source: :list, inverse_of: :notes

	has_many :note_groups, inverse_of: :note, dependent: :destroy
	has_many :groups, through: :note_groups, inverse_of: :notes

	def normalize
		self.recipient_ids = self.class.commas_to_array(alerted_user_ids)
		self.entities = Entity.unscoped.find(self.class.commas_to_array(read_attribute(:entity_ids)))
		self.relationships = Relationship.unscoped.find(self.class.commas_to_array(read_attribute(:relationship_ids)))
		self.lists = List.unscoped.find(self.class.commas_to_array(lslist_ids))
		self.group_ids = Group.joins("LEFT JOIN sf_guard_group gg ON groups.slug = gg.name")
										 .where("gg.id" => self.class.commas_to_array(sfguardgroup_ids)).pluck(:id)
		self.networks = List.unscoped.find(self.class.commas_to_array(read_attribute(:network_ids)))
	end

	def self.commas_to_array(str)
		return [] if str.blank?
		str.chomp(",").reverse.chomp(",").reverse.split(",")
	end
end
