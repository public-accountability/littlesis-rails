ThinkingSphinx::Index.define :ny_filer, :with => :active_record do
  indexes name

  has filer_id
  has committee_type
  has filer_type
  has office
  has district
end
