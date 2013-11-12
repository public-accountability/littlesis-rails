namespace :users do
  desc "creates a User for each SfGuardUserProfile"
  task create_all_from_profiles: :environment do
  	User.create_all_from_profiles
  end
end
