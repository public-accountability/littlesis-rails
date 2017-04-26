require Rails.root.join('lib', 'task-helpers', 'nys_campaign_finance.rb')

namespace :nys do
  desc 'import latest donation data'
  task :disclosure_import, [:file] => :environment do |t, args|
    puts "dropping and re-creating #{NYSCampaignFinance::STAGING_TABLE_NAME}"
    NYSCampaignFinance.drop_staging_table
    NYSCampaignFinance.create_staging_table
    puts "Importing file: #{args[:file]}"
    NYSCampaignFinance.import_disclosure_data(args[:file])
  end
end
