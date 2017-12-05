class Note < ActiveRecord::Base
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  include SingularTable

  include Rails.application.routes.url_helpers

  belongs_to :user, foreign_key: "new_user_id", inverse_of: :notes
  belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :notes

  has_many :note_recipients, class_name: "NoteUser", inverse_of: :note, dependent: :destroy
  has_many :recipients, through: :note_recipients, source: :user, inverse_of: :received_notes

  has_many :note_entities, inverse_of: :note, dependent: :destroy
  has_many :entities, through: :note_entities

  has_many :note_relationships, inverse_of: :note, dependent: :destroy
  has_many :relationships, through: :note_relationships

  has_many :note_lists, inverse_of: :note, dependent: :destroy
  has_many :lists, through: :note_lists

  has_many :note_networks, inverse_of: :note, dependent: :destroy
  has_many :networks, class_name: "List", through: :note_networks, inverse_of: :network_notes

  has_many :note_groups, inverse_of: :note, dependent: :destroy
  has_many :groups, through: :note_groups

  scope :public_scope, -> { where(is_private: false) }
  scope :private_scope, -> { where(is_private: true) }
  scope :with_joins, -> { 
    joins("LEFT JOIN note_users ON note_users.note_id = note.id")
      .joins("LEFT JOIN users ON users.id = note_users.user_id")		
      .group("note.id")
      .order("note.created_at DESC")
  }

	# before_save :parse

	def readonly?
		false
	end

	def set_new_user_id
		self.new_user_id = User.where(sf_guard_user_id: user_id).pluck(:id).first
	end

	def normalize
		self.recipients = User.where(sf_guard_user_id: self.class.commas_to_array(alerted_user_ids))
		self.entities = Entity.unscoped.find(self.class.commas_to_array(read_attribute(:entity_ids)))
		self.relationships = Relationship.unscoped.find(self.class.commas_to_array(read_attribute(:relationship_ids)))
		self.lists = List.unscoped.find(self.class.commas_to_array(lslist_ids))
		self.groups = Group.joins(:sf_guard_group).where("sf_guard_group.id" => self.class.commas_to_array(sfguardgroup_ids))
		self.networks = List.unscoped.find(self.class.commas_to_array(read_attribute(:network_ids)))
		self
	end

	def legacy_denormalize
		write_attribute(:user_id, user.sf_guard_user_id)

		if recipients.present?
			self.alerted_user_names = legacy_denormalize_ary(recipients.map(&:username))
			self.alerted_user_ids = legacy_denormalize_ary(recipients.map(&:sf_guard_user_id))
		end

		write_attribute(:entity_ids, entities.present? ? legacy_denormalize_ary(entities.map(&:id)) : [])
		write_attribute(:relationship_ids, relationships.present? ? legacy_denormalize_ary(relationships.map(&:id)) : [])
		write_attribute(:lslist_ids, entities.present? ? legacy_denormalize_ary(lists.map(&:id)) : [])
		write_attribute(:sfguardgroup_ids, groups.present? ? legacy_denormalize_ary(groups.collect { |g| g.sf_guard_group.id if g.sf_guard_group.present? }) : [])
		write_attribute(:network_ids, legacy_denormalize_ary(network_ids))
		self
	end

	def legacy_denormalize_ary(ids)
		return nil if ids.blank?
		"," + ids.join(",") + ","
	end

	def self.commas_to_array(str)
		return [] if str.blank?
		str.chomp(",").reverse.chomp(",").reverse.split(",").uniq
	end

	def self.username_chars
		"a-zA-Z0-9._"
	end

	def parse
		matches = body_raw.scan /@([#{self.class.username_chars}]+)(?!([a-zA-Z0-9]|:\d))/i
		usernames = matches.map(&:first)
		self.recipients = User.where(username: usernames)

		matches = body_raw.scan /@entity:(\d+)/i
		entity_ids = matches.map(&:first)
		self.entities = Entity.where(id: entity_ids)

		matches = body_raw.scan /@rel:(\d+)/i
		rel_ids = matches.map(&:first)
		self.relationships = Relationship.where(id: rel_ids)

		matches = body_raw.scan /@list:(\d+)/i
		list_ids = matches.map(&:first)
		self.lists = List.where(id: list_ids)

		matches = body_raw.scan /@group:(\d+)/i
		group_ids = matches.map(&:first)
		groups = legacy? ? Group.joins(:sf_guard_group).where("sf_guard_group.id" => group_ids) : Group.where(id: group_ids)

		matches = body_raw.scan /@group:([#{self.class.username_chars}]+)/i
		group_slugs = matches.map(&:first)
		self.groups = groups + Group.where(slug: group_slugs)

		self
	end

	def legacy?
		is_legacy
	end

	def private?
		is_private
	end

	def public?
		!is_private
	end

	def all_users
		[user] + recipients
	end

	def all_user_ids
		[new_user_id] + recipient_ids
	end

	def visible_to?(user)
		return public? if user.nil?
		return false if user.nil?
		return true unless private?
		return true if all_user_ids.include?(user.id)
		return false
	end

	def self.visible_to_user(user)
		if user.nil?
			return Note.with_joins.public_scope
		end

  	Note.with_joins
  		.where("note.is_private = ? OR note.new_user_id = ? OR users.id = ?", false, user.id, user.id)
	end

	def set_visible_to_user_ids
		self.visible_to_user_ids = recipient_ids + [new_user_id] + (public? ? [0] : nil)
	end

	# for cleaning up duplicate note_entities created before the table had a unique index
	def destroy_duplicate_note_entities
		entity_ids = note_entities.select("entity_id, COUNT(*) AS num").group(:entity_id).having("num > 1").map(&:entity_id)
		entity_ids.each do |entity_id|
			note_entities.where(entity_id: entity_id).destroy_all
			entities << Entity.unscoped.find(entity_id)
		end
	end

	# for cleaning up duplicate note_relationships created before the table had a unique index
	def destroy_duplicate_note_relationships
		relationship_ids = note_relationships.select("relationship_id, COUNT(*) AS num").group(:relationship_id).having("num > 1").map(&:relationship_id)
		relationship_ids.each do |relationship_id|
			note_relationships.where(relationship_id: relationship_id).destroy_all
			relationships << Relationship.unscoped.find(relationship_id)
		end
	end

	def clear_related_cache
		Rails.cache.delete_matched("views/notes/index/*")

		all_users.each do |user|
			user.clear_cache('home/notes')
			user.clear_cache('notes/notes')
			user.clear_cache('dashboard/notes')
		end

		groups.each do |group|
			group.clear_cache('show/notes')
			group.clear_cache('notes/notes')
		end
	end

        def render_body(override=false)
          ''
        end

	def convert_new_legacy
		return unless new_user_id.nil?
		set_new_user_id
		normalize
		self.is_legacy = true
		save
	end

	def self.convert_all_new_legacy
		where("new_user_id is null").each do |note|
      note.convert_new_legacy
    end
	end

  def self.entity_markup(entity)
    "@entity:#{entity.id}[#{entity.name}]"
  end

  def self.list_markup(list)
  	"@list:#{list.id}[#{list.name}]"
  end
end
