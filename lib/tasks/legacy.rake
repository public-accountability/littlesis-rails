namespace :legacy do
  desc "Archive networks"
  task archive_networks: :environment do
    DB = Rails.configuration.database_configuration['production']
    filepath = Rails.root.join('data', 'network_entity_archive.sql').to_s
    cmd = "mysqldump -u #{DB['username']} -p#{DB['password']} -h #{DB['host']} --single-transaction --where=\"list_id IN (78,79,96,132,133,198)\" #{DB['database']} ls_list_entity > #{filepath}"
    `#{cmd}`
    puts "Saved to: #{filepath}"
  end

  desc "the one task you need to run to prep a legacy (symfony) littlesis database for use by this applicaton"
  task convert_data: [
  	:environment, 
  	:'users:create_all_from_profiles', 
  	:'groups:create_all_from_guard_groups',
  	:'groups:create_all_group_lists_from_guard_group_lists',
  	:'groups:create_all_group_users_from_guard_user_groups',
  	:'notes:set_all_new_users',
  	:'notes:normalize_all',
  	:'notes:make_all_legacy'
  ] do
  	print "All set!\n"
  end
end
