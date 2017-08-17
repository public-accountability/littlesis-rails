ThinkingSphinx::Index.define :list, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
  indexes name, sortable: true
  indexes description
  indexes short_description

  has is_deleted, facet: true
  has is_admin, facet: true
  has is_network, facet: true
  has access, facet: true
  has updated_at
end
