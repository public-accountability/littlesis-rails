# require Rails.root.join('lib', 'nys_campaign_finance.rb')
require Rails.root.join('lib', 'nys_disclosure_importer.rb').to_s

namespace :nys do
  desc 'download nys disclosures'
  task download: :environment do
    NYSDisclosureImporter.run
  end

  # desc 'import latest donation data to staging table'
  # task :disclosure_import, [:file] => :environment do |t, args|
  #   puts "dropping and re-creating #{NYSCampaignFinance::STAGING_TABLE_NAME}"
  #   NYSCampaignFinance.drop_staging_table
  #   NYSCampaignFinance.create_staging_table
  #   puts "Importing file: #{args[:file]}"
  #   NYSCampaignFinance.import_disclosure_data(args[:file])
  # end

  # desc 'insert new ny disclosures from staging'
  # task :disclosure_update, [:dry_run] => :environment do |t, args|
  #   NYSCampaignFinance.insert_new_disclosures(args[:dry_run].present?)
  # end

  # desc 'Remove all NyDisclosures expect those with matches'
  # task cull_disclosures: :environment do
  #   where = "id NOT IN (#{NyMatch.pluck(:ny_disclosure_id).join(',')})"
  #   puts "Deleting #{NyDisclosure.where(where).count} of #{NyDisclosure.count} disclosures"
  #   NyDisclosure.delete_all(where)
  #   puts "There are now #{NyDisclosure.count} disclosures"
  # end

  # desc 'Removes disclosures from staging table NOT in the provided years. example: nys:limit_staging_to_years[2017,2018]'
  # task :limit_staging_to_years, [:*] => :environment  do |_ , args|
  #   years = args.to_a.length.zero? ? Array.wrap(Time.now.year.to_s) : args.to_a
  #   NYSCampaignFinance.limit_staging_to_years(years)
  # end

  # desc 'Import new NYS filers (COMMCAND data)'
  # task :filer_import, [:file] => :environment do |t, args|
  #   NYSCampaignFinance.insert_new_filers(args[:file])
  # end
end
