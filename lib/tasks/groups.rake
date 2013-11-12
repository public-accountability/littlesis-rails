namespace :groups do
  desc "creates a Group for each SfGuardGroup"
  task create_all_from_guard_groups: :environment do
  	SfGuardGroup.all.each do |gg|
  		gg.create_group
  	end
  end
end
