namespace :mysql do
  desc "Creates raw public dataset"
  task public_data: :environment do
    DB = Rails.configuration.database_configuration['production']

    tables = [
      'alias',
      'address_category',
      'address_country',
      'address_state',
      'business',
      'business_industry',
      'business_person',
      'candidate_district',
      'couple',
      'custom_key',
      'degree',
      'donation',
      'education',
      'elected_representative',
      'entity',
      'entity_fields',
      'extension_definition',
      'extension_record',
      'family',
      'fedspending_filing',
      'fields',
      'gender',
      'generic',
      'government_body',
      'hierarchy',
      'industries',
      'industry',
      'link',
      'lobby_filing',
      'lobby_filing_lobby_issue',
      'lobby_filing_lobbyist',
      'lobby_filing_relationship',
      'lobby_issue',
      'lobbying',
      'lobbyist',
      'membership',
      'org',
      'ownership',
      'person',
      'political_candidate',
      'political_district',
      'political_fundraising',
      'political_fundraising_type',
      'position',
      'professional',
      'public_company',
      'relationship_category',
      'representative',
      'representative_district',
      'school',
      'social',
      'transaction',
      #these tables need to be cleaned afterwards
      'entity',
      'relationship',
      'reference',
      'reference_excerpt'
    ]

     cmd = "mysqldump -u #{DB['username']} -p#{DB['password']} -h #{DB['host']} --single-transaction #{DB['database']} #{tables.join(' ')} > ~/ls_public_data_raw.sql"
     
     puts "Running command: #{cmd}"

     `#{cmd}`

    # our app user doesn't have correct permissions right now to run 'aws s3'
    # puts "Copying to aws"
    # aws_cmd = "aws s3 cp ~/ls_public_data_raw.sql s3://pai-littlesis/public-data/littlesis-public-data-#{Date.today.strftime.gsub('-', '')}.sql"
    # puts "Running command: #{aws_cmd}"
    # `#{aws_cmd}`
     
  end
end
