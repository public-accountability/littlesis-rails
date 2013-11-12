class Note < ActiveRecord::Base
  include SingularTable

	belongs_to :user, inverse_of: :notes

	has_many :note_recipients, class_name: "NoteUser", inverse_of: :note
	has_many :recipients, through: :note_recipients, source: :user, inverse_of: :received_notes

	has_many :note_entities, inverse_of: :note
	has_many :entities, through: :note_entities, inverse_of: :notes

	has_many :note_relationships, inverse_of: :note
	has_many :relationships, through: :note_relationship, inverse_of: :notes

	has_many :note_lists, inverse_of: :note
	has_many :lists, -> { where(is_network: false) }, through: :note_lists, inverse_of: :notes
	has_many :networks, -> { where(is_network: true) }, through: :note_lists, source: :list, inverse_of: :notes

	has_many :note_groups, inverse_of: :note
	has_many :groups, through: :note_group, inverse_of: :notes

	def normalize
		recipient_ids = self.class.commas_to_array(alerted_user_ids)
		entity_ids = self.class.commas_to_array(read_attribute(:entity_ids))
		relationship_ids = self.class.commas_to_array(read_attribute(:relationship_ids))
		list_ids = self.class.commas_to_array(lslist_ids)
		groups_ids = self.class.commas_to_array(sfguardgroup_ids)
		network_ids = self.class.commas_to_array(read_attribute(:network_ids))
	end

	def self.commas_to_array(str)
		return [] if str.blank?
		str.chomp(",").reverse.chomp(",").reverse.split(",")
	end
end
