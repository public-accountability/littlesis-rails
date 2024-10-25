ThinkingSphinx::Index.define :list, :with => :real_time do
  indexes name, sortable: true
  indexes description
  indexes short_description

  has is_featured, type: :boolean
  has is_deleted, type: :boolean
  has id, as: :id_number, type: :integer
  has access, type: :integer
  has entity_count, type: :integer
  has created_at, type: :timestamp
  has updated_at, type: :timestamp
  has creator_user_id, type: :bigint
end
