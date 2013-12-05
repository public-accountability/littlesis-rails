namespace :groups do
  desc "creates a Group for each SfGuardGroup"
  task create_all_from_guard_groups: :environment do
  	SfGuardGroup.working.each do |gg|
  		gg.create_group
  	end
    print "created Groups based on legacy SfGuardGroups\n"
  end

  desc "creates a GroupList for each SfGuardGroupList"
  task create_all_group_lists_from_guard_group_lists: :environment do
  	SfGuardGroupList.joins(:sf_guard_group).all.each do |gl|
  		gl.create_group_list if gl.sf_guard_group.is_working
  	end
    print "created GroupLists based on legacy SfGuardGroupLists\n"
  end

  desc "creates a GroupUser for each SfGuardUserGroup"
  task create_all_group_users_from_guard_user_groups: :environment do
  	SfGuardUserGroup.joins(:sf_guard_group).all.each do |ug|
  		ug.create_group_user if ug.sf_guard_group.is_working
  	end
    print "created GroupUsers based on legacy SfGuardGroupUsers\n"
  end
end
