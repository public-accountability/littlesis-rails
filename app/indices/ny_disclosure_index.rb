# ThinkingSphinx::Index.define :ny_disclosure, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
#   indexes first_name
#   indexes last_name
#   indexes corp_name

#   join ny_match
#   has "if(ny_matches.id is null, FALSE, TRUE)", :as => :is_matched, :type => :boolean

#   has filer_id
#   has report_id
#   has transaction_code
#   has e_year
#   has contrib_code
#   has contrib_type_code
#   has amount1
# end
