class CongressLegislator < Entity

	# Takes a YAML object from this data file: https://github.com/unitedstates/congress-legislators
	def initialize
		super
		
		@name = find_best_name
		@blurb = build_blurb
		@primary_ext = 'Person'
		@types = ['ElectedRepresentative']
		@start_date = '2000-01-01'
		@end_date = '2000-01-01'
	end

	def find_best_name 
		"Firstname Lastname"
	end

	def build_blurb 
		"blurby blurb blurb"
	end
end
