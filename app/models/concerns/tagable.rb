module Tagable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :tagable, foreign_type: :tagable_class
    has_many :tags, through: :taggings
  end

  TAGABLE_CLASSES = [Entity, List, Relationship]

  # sorts a list of tagables in descending order of relationships to tagables w/ same tag
  def self.sort_by_related_tagables(tagables)
    tagables
  end

  def self.page_param_of(klass_name)
    (klass_name.to_s.downcase + "_page").to_sym
  end

  # [String|Int] -> Tagable
  def update_tags(ids)
    server_tag_ids = tags.map(&:id).to_set
    client_tag_ids = ids.map(&:to_i).to_set
    actions = Tag.parse_update_actions(client_tag_ids, server_tag_ids)

    actions[:remove].each { |tag_id| remove_tag(tag_id) }
    actions[:add].each { |tag_id| tag(tag_id) }
    self
  end

  def tag(name_or_id)
    Tagging.find_or_create_by(tag_id:         parse_tag_id!(name_or_id),
                              tagable_class:  self.class.name,
                              tagable_id:     self.id)
  end

  def remove_tag(name_or_id)
    taggings
      .find_by_tag_id(parse_tag_id!(name_or_id))
      .destroy
  end

  def tags_for(user)
    {
      byId: hashify(add_permissions(Tag.all, user)),
      current: tags.map(&:id).map(&:to_s)
    }
  end

  private

  # NOTE: does NOT allow string-intergers as ids .ie. '1'
  def parse_tag_id!(name_or_id)
    msg = name_or_id.is_a?(String) ? :find_by_name! : :find
    Tag.public_send(msg, name_or_id).id
  end

  # Array[Tag] -> Hash{[id:string]: Tag}
  def hashify(tags)
    tags.reduce({}) do |acc, t|
      acc.merge(t['id'].to_s => t)
    end
  end

  # (Array[Tag], User) -> Array[AugmentedTag]
  def add_permissions(tags, user)
    tags.map do |t|
      t.attributes.merge('permissions' => user.permissions.tag_permissions(t))
    end
  end
end
