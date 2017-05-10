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

  desc 'Remove all NyDisclosures expect those with matches'
  task cull_disclosures: :environment do
    where = "id NOT IN (#{NyMatch.pluck(:ny_disclosure_id).join(',')})"
    puts "Deleting #{NyDisclosure.where(where).count} of #{NyDisclosure.count} disclosures"
    NyDisclosure.delete_all(where)
    puts "There are now #{NyDisclosure.count} disclosures"
  end
end
