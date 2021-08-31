ThinkingSphinx::Index.define :entity, :with => :real_time do
  indexes name, sortable: true
  indexes blurb
  indexes summary
  indexes also_known_as_index, as: :aliases
  indexes person.name_nick, as: :name_nick

  has primary_ext, type: :string
  has is_deleted, type: :boolean
  has last_user_id, type: :integer
  has updated_at, type: :timestamp
  has link_count, type: :integer
  has tag_ids, as: :tag_ids, multi: true, type: :integer
  has region_numbers, as: :regions, multi: true, type: :integer
end
