namespace :legislators do
	desc 'Returns list of legislators from the YAML file who may not be in our database, or whose entries are incomplete'
	task unmatched: :environment do
		matcher = LegislatorMatcher.new
		matcher.find_unmatched
	end

	desc 'Prints count of legislators from the YAML file who may not be in our database, or whose entries are incomplete'
	task unmatched_count: :environment do
		matcher = LegislatorMatcher.new
		puts matcher.find_unmatched.count
	end

	desc 'Matches legislators to Entity ids; returns array of tuples: [Entity id, YAML object]'
	task match: :environment do
		matcher = LegislatorMatcher.new
		matcher.match
	end

	desc 'test method'
	task test_method: :environment do
		matcher = LegislatorMatcher.new
		matcher.test_method
	end
end
