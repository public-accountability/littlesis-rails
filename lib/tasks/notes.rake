namespace :notes do
	desc "copies user_id to sf_guard_user_id and replaces with User.id for each Note"
	task update_all_legacy_users: :environment do
		Note.all.each do |note|
			note.update_legacy_user_id
			note.save
		end
	end


  desc "normalizes legacy relational fields for each Note"
  task normalize_all: :environment do
  	Note.all.each do |note|
  		note.normalize
  	end
  end
end
