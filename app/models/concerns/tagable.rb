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

  def tags_for(user = nil)
    {
      byId: hashify(add_permissions(Tag.all, user)),
      current: tags.map(&:id).map(&:to_s)
    }
  end

  private

  # NOTE: does NOT allow string-intergers as ids .ie. '1'
  def parse_tag_id!(name_or_id)
    return if name_or_id == 0

    msg = name_or_id.is_a?(String) ? :find_by_name! : :find
    Tag.public_send(msg, name_or_id).id
  end

  # Array[Tag] -> Hash{[id:string]: Tag}
  def hashify(tags)
    tags.reduce({}) do |acc, t|
      acc.merge(t['id'].to_s => t.with_indifferent_access)
    end
  end

  # (Array[Tag], User) -> Array[AugmentedTag]
  def add_permissions(tags, user)
    tags.map do |t|
      permissions = if user
                      user.permissions.tag_permissions(t)
                    else
                      { :viewable => true, :editable => false }
                    end

      t.attributes.merge('permissions' => permissions)
    end
  end
end
