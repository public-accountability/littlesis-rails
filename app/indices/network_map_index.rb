ThinkingSphinx::Index.define :network_map, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
  indexes title, sortable: true
  indexes description
  indexes index_data

  has [is_private, user_id], as: :visible_to_user_ids, multi: true, type: :integer
  has is_private, facet: true
  has is_featured, facet: true
  has is_deleted, facet: true
  has user_id, facet: true
  has updated_at
end