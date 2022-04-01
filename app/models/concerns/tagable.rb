# frozen_string_literal: true

module Tagable
  extend ActiveSupport::Concern

  # Class methods on Tagable

  # () -> Array[ClassConstant]
  def self.classes
    @classes ||= [Entity, List, Relationship].freeze
  end

  # () -> Array[Symbol]
  def self.categories
    @categories ||= classes.map(&:category_sym).freeze
  end

  # str|sym -> ClassConstant
  def self.class_of(category)
    category.to_s.singularize.classify.constantize
  end

  # Instance methods on Tagable instances

  included do
    has_many :taggings, as: :tagable, foreign_type: :tagable_class
    has_many :tags, through: :taggings
  end

  # Class methods on Tagable instances

  class_methods do
    def category_str
      name.downcase.pluralize
    end

    def category_sym
      category_str.to_sym
    end
  end

  # CRUD METHODS

  def add_tag(name_or_id, user_id = User.system_user_id)
    t = Tagging
          .find_or_initialize_by(tag_id:         parse_tag_id!(name_or_id),
                                 tagable_class:  self.class.name,
                                 tagable_id:     id)
    t.update(last_user_id: user_id) unless t.persisted?
    self
  end

  def add_tag_without_callbacks(name_or_id, user_id = Rails.application.config.littlesis[:system_user_id])
    Tagging.skip_callback(:save, :after, :update_tagable_timestamp)
    add_tag(name_or_id, user_id)
  ensure
    Tagging.set_callback(:save, :after, :update_tagable_timestamp)
  end

  def remove_tag(name_or_id)
    taggings
      .find_by_tag_id(parse_tag_id!(name_or_id))
      .destroy
  end

  # [String|Int] -> Tagable
  def update_tags(ids, admin: false)
    server_tag_ids = tags.map(&:id).to_set
    client_tag_ids = ids.map(&:to_i).to_set

    # add back restricted tags
    unless admin
      (server_tag_ids & Tag.restricted_tags.map(&:id)).each do |tag_id|
        client_tag_ids << tag_id
      end
    end

    actions = Tag.parse_update_actions(client_tag_ids, server_tag_ids)

    actions[:remove].each { |tag_id| remove_tag(tag_id) }
    actions[:add].each { |tag_id| add_tag(tag_id) }
    self
  end

  # Gets data on tags and their permissions for the provided user
  # See views/entities/_sidebar_tags
  # @param user [User, Nil]
  # @return Hash[:byId => Array[Hash], :current => Array[String]]
  def tags_for(user = nil)
    {
      byId: Tag.all_tags_with_user_permissions_byid(user),
      current: tags.map { |t| t.id.to_s }
    }.tap do |h|
      h.define_singleton_method(:options) do
      fetch(:byId).values.lazy
        .select { |t| t.dig('permissions', 'editable') }
        .map { |t| [t['name'], t['id'].to_s] }
        .force
      end
    end
  end

  private

  # NOTE: does NOT allow string-intergers as ids .ie. '1'
  def parse_tag_id!(name_or_id)
    return if name_or_id == 0

    msg = name_or_id.is_a?(String) ? :find_by_name! : :find
    Tag.public_send(msg, name_or_id).id
  end
end
