require 'development_db'

namespace :database do
  namespace :dump do
    desc 'Creates raw public dataset'
    task :public => :environment do
      DevelopmentDb.new(:public).run
    end

    desc 'Creates development database'
    task development: :environment do
      DevelopmentDb.new(:development).run
      ddb.run
    end

    desc 'Saves open secrets tables'
    task open_secrets: :environment do
      DevelopmentDb.new(:open_secrets).run
    end

    desc 'Saves external_data'
    task external_data: :environment do
      DevelopmentDb.new(:external_data).run
    end
  end
end
