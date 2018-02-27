ThinkingSphinx::Index.define :entity, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
  indexes name, sortable: true
  indexes blurb
  indexes summary
  indexes aliases.name, as: :aliases

  has primary_ext
  has is_deleted, facet: true
  has last_user_id, facet: true
  has updated_at
  has networks.id, as: :network_ids
  has link_count

  set_property :morphology => "stem_en, metaphone"
end
