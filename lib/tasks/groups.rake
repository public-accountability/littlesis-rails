namespace :groups do
  desc "creates a Group for each SfGuardGroup"
  task create_all_from_guard_groups: :environment do
  	SfGuardGroup.all.each do |gg|
  		gg.create_group
  	end
  end

  desc "creates a GroupList for each SfGuardGroupList"
  task create_all_group_lists_from_guard_group_lists: :environment do
  	SfGuardGroupList.all.each do |gl|
  		gl.create_group_list
  	end
  end
end
