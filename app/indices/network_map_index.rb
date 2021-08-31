ThinkingSphinx::Index.define :network_map, :with => :real_time do
  indexes title, sortable: true
  indexes description
  indexes index_data

  has is_private, type: :boolean
  has is_featured, type: :boolean
  has is_deleted, type: :boolean
  has user_id, type: :integer
  has updated_at, type: :timestamp
end
