ThinkingSphinx::Index.define :group, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
  indexes name, sortable: true
  indexes tagline
  indexes description
  indexes slug
  indexes findings

  has is_private
  has created_at
end