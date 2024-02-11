namespace :public_data do
  desc "generates entities.json and relationships.json"
  task :run => :environment do
    PublicData.run
  end
end
