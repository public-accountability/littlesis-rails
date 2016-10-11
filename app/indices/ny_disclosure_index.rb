ThinkingSphinx::Index.define :ny_disclosure, :with => :real_time do
  indexes first_name
  indexes last_name
  indexes full_name
  indexes corp_name

  has is_matched, :type => :boolean
  has filer_id, :type => :string
  has report_id, :type => :string
  has transaction_code, :type => :string
  has e_year, :type => :string
  has contrib_code, :type => :string
  has contrib_type_code, :type => :string
  has amount1, :type => :float
end
