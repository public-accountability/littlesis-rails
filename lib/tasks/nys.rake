require Rails.root.join('lib', 'task-helpers', 'nys_campaign_finance.rb')

namespace :nys do
  desc 'import latest donation data to staging table'
  task :disclosure_import, [:file, :dry_run] => :environment do |t, args|
    puts "This is a dry run" if args[:dry_run].present?
    puts "dropping and re-creating #{NYSCampaignFinance::STAGING_TABLE_NAME}"
    unless args[:dry_run]
      NYSCampaignFinance.drop_staging_table
      NYSCampaignFinance.create_staging_table
    end
    puts "Importing file: #{args[:file]}"
    NYSCampaignFinance.import_disclosure_data(args[:file], args[:dry_run].present?)
  end

  desc 'insert new ny disclosures from staging'
  task :disclosure_update, [:dry_run] => :environment do |t, args|
    NYSCampaignFinance.insert_new_disclosures(args[:dry_run].present?)
  end

  desc 'Remove all NyDisclosures expect those with matches'
  task cull_disclosures: :environment do
    where = "id NOT IN (#{NyMatch.pluck(:ny_disclosure_id).join(',')})"
    puts "Deleting #{NyDisclosure.where(where).count} of #{NyDisclosure.count} disclosures"
    NyDisclosure.delete_all(where)
    puts "There are now #{NyDisclosure.count} disclosures"
  end

  desc 'Remove all NyDisclosures expect those with matches'
  task :filer_import, [:file] => :environment do |t, args|
    NYSCampaignFinance.insert_new_filers(args[:file])
  end
end
