namespace :notes do
	desc "copies user_id to new_user_id and replaces with User.id for each Note"
	task set_all_new_users: :environment do
		Note.all.each do |note|
			note.set_new_user_id
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
