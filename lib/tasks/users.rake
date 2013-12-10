namespace :users do
  desc "creates a User for each SfGuardUserProfile"
  task create_all_from_profiles: :environment do
  	SfGuardUserProfile.all.each do |p| 
  		p.create_user_with_email_password
  	end
  	print "created Users based on legacy SfGuardUsers\n"
  end

  desc "creates a User for each new SfGuardUserProfile that doesn't already have one"
  task create_from_new_profiles: :environment do
  	SfGuardUserProfile.without_user.each do |p|
  		p.create_user_with_email_password
  	end
  	print "created Users based on new SfGuardUserProfiles\n"
  end
end
