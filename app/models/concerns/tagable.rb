module Tagable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :tagable
  end

  # [String|Int] -> Tagable
  def update_tags(ids)
    server_tag_ids = tags.map { |t| t[:id] }.to_set
    client_tag_ids = ids.map(&:to_i).to_set
    actions = Tag.parse_update_actions(client_tag_ids, server_tag_ids)

    actions[:remove].each { |tag_id| remove_tag(tag_id) }
    actions[:add].each { |tag_id| tag(tag_id) }
    self
  end
  
  def tag(name_or_id)
    Tagging.find_or_create_by(tag_id:         Tag.find!(name_or_id)[:id],
                              tagable_class:  self.class.name,
                              tagable_id:     self.id)
  end

  def remove_tag(name_or_id)
    id = Tag.find!(name_or_id)[:id]
    taggings.find_by_tag_id(id).destroy
  end
  
  def tags
    taggings.map { |tagging| Tag.find(tagging.tag_id) }
  end

  def taggings
    Tagging.where(tagable_id: self.id, tagable_class: self.class.name)
  end

  def tags_for(user)
    {
      byId: hashify(add_permissions(Tag.all, user)),
      current: tags.map(&:id).map(&:to_s)
    }
  end

  private

  # Array[Tag] -> Hash{[id:string]: Tag}
  def hashify(tags)
    tags.reduce({}) do |acc, t|
      acc.merge(t[:id].to_s => t)
    end
  end

  # (Array[Tag], User) -> Array[AugmentedTag]
  def add_permissions(tags, user)
    tags.map do |t|
      t.merge('permissions' => user.permissions.tag_permissions(t))
    end
  end
end
