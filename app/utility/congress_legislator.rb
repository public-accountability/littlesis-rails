class CongressLegislator < ElectedRepresentative

	# Takes a YAML object from this data file: https://github.com/unitedstates/congress-legislators
	def initialize(rep)
		@name = find_best_name(rep)
		@blurb = build_blurb(rep)
		@primary_ext = 'Person'
		@types = ['ElectedRepresentative']
	end

end
