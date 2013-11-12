namespace :notes do
  desc "normalizes legacy relational fields for each Note"
  task normalize_all: :environment do
  	Note.all.each do |note|
  		note.normalize
  	end
  end
end
