ThinkingSphinx::Index.define :list, :with => :real_time do
  indexes name, sortable: true
  indexes description
  indexes short_description

  has is_featured, type: :boolean
  has is_deleted, type: :boolean
  has is_admin, type: :boolean
  has access, type: :integer, facet: true
  has entity_count, type: :integer, facet: true
  has updated_at, type: :timestamp
end
