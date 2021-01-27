ThinkingSphinx::Index.define :entity, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
  indexes name, sortable: true
  indexes blurb
  indexes summary
  indexes aliases.name, as: :aliases
  indexes person.name_nick, as: :name_nick

  has primary_ext
  has is_deleted, facet: true
  has last_user_id, facet: true
  has updated_at
  has link_count
  has taggings.tag_id, as: :tag_ids, facet: true
  has locations.region, as: :regions, facet: true
end
