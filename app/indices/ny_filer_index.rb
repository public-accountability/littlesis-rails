# ThinkingSphinx::Index.define :ny_filer, :with => :active_record do
#   indexes name

#   join ny_filer_entity

#   has filer_id
#   has committee_type
#   has filer_type
#   has office
#   has district
#   has 'COUNT(ny_filer_entities.id) > 0', :as => :is_matched, :type => :boolean
# end
