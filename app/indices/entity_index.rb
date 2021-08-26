ThinkingSphinx::Index.define :entity, :with => :real_time do
  indexes name, sortable: true
  indexes blurb
  indexes summary
  indexes aliases.name, as: :aliases
  indexes person.name_nick, as: :name_nick

  has primary_ext, type: :string
  has is_deleted, type: :boolean, facet: true
  has last_user_id, type: :integer, facet: true
  has updated_at, type: :timestamp
  has link_count, type: :integer
  has taggings.tag_id, as: :tag_ids, type: :integer, facet: true
  has locations.region, as: :regions, type: :string, facet: true
end
