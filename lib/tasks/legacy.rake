namespace :legacy do
  desc "the one task you need to run to prep a legacy (symfony) littlesis database for use by this applicaton"
  task convert_data: [
  	:environment, 
  	:'users:create_all_from_profiles', 
  	:'groups:create_all_from_guard_groups',
  	:'groups:create_all_group_lists_from_guard_group_lists',
  	:'groups:create_all_group_users_from_guard_group_users',
  	:'notes:set_all_new_users',
  	:'notes:normalize_all',
  	:'notes:make_all_legacy'
  ] do
  	print "All set!\n"
  end
end