ThinkingSphinx::Index.define :industry, :with => :active_record do
  indexes name, sortable: true
  indexes sector_name, sortable: true

  has industry_id
end