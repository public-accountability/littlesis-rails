namespace :users do
  desc "creates a User for each SfGuardUserProfile"
  task create_all_from_profiles: :environment do
  	SfGuardUserProfile.all.each do |p| 
  		p.create_user_with_email_password
  	end
  	print "created Users base on legacy SfGuardUsers\n"
  end
end
