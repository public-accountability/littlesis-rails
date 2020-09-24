require 'development_db'

namespace :mysql do
  desc 'Creates raw public dataset'
  task public_data: :environment do
    DB = Rails.configuration.database_configuration['production']
    tables = DevelopmentDb::PUBLIC_DATA
    cmd = "mysqldump -u #{DB['username']} -p#{DB['password']} -h #{DB['host']} --single-transaction #{DB['database']} #{tables.join(' ')} > ~/ls_public_data_raw.sql"
    puts "Saving raw public data to ~/ls_public_data_raw.sql"
    `#{cmd}`

    # our app user doesn't have correct permissions right now to run 'aws s3'
    # puts "Copying to aws"
    # aws_cmd = "aws s3 cp ~/ls_public_data_raw.sql s3://pai-littlesis/public-data/littlesis-public-data-#{Date.today.strftime.gsub('-', '')}.sql"
    # puts "Running command: #{aws_cmd}"
    # `#{aws_cmd}`
  end

  desc 'creates development database'
  task development_db: :environment do
    ddb = DevelopmentDb.new(Rails.root.join('data', "development_db_#{Time.now.strftime('%F')}.sql").to_s)
    ddb.run
  end

  desc 'dumps open secrets tables'
  task open_secrets: :environment do
    path = Rails.root.join('data', "open_secrets_data_#{Time.now.strftime('%F')}.sql").to_s
    DevelopmentDb.new(path).open_secrets
  end
end
