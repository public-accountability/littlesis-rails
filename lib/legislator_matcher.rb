require 'open-uri'
require 'uri'

class LegislatorMatcher
	# include Rails.application.routes.url_helpers

	def initialize
		open 'https://theunitedstates.io/congress-legislators/legislators-current.yaml' do |f| 
			@current_reps = YAML.load_file f 
		end

		open 'https://theunitedstates.io/congress-legislators/legislators-historical.yaml' do |f|
			@historical_reps = YAML.load_file f
		end 
		
		# Reps since 1990, returns array of YAML objects
		@reps = @historical_reps.select { |rep| rep['terms'].any? { |term| term['end'] >= '1990-00-00' } } | @current_reps
	end


	# Either no associated id, or not in the database at all
	def find_unmatched
		unmatched_by_ids @reps
	end

	# In the database, but maybe their entry doesn't include their elected position
	# def find_outdated
	# 	(unmatched_by_ids @reps).select { |rep| search_by_rep(rep).count > 0 }
	# end

	def match
		@reps.map { |rep| [(match_by_ids rep), rep] }
	end

	def test_method
		find_unmatched.each { |rep| p match_by_name rep }
	end

	private

	# Takes YAML object, returns either Entity id number or nil if they can't be found
	def match_by_ids rep
		bioguide_id, govtrack_id, crp_id = rep['id']['bioguide'], rep['id']['govtrack'], rep['id']['opensecrets']
		elected_representative = ElectedRepresentative.find_by(crp_id: crp_id) || ElectedRepresentative.find_by(bioguide_id: bioguide_id) || ElectedRepresentative.find_by(govtrack_id: govtrack_id)
		elected_representative ? elected_representative.entity_id : nil
	end

	# Takes YAML object, returns either a definite Entity matches or [] if they can't be found
	def match_by_name rep
		p ''
		p rep['name']

		by_name = (search_by_full_name rep) | (search_by_name rep['id']['wikipedia']) | (search_by_name rep['name']['last'])
		filter_by_birth_date by_name, rep['bio']['birthday']
	end

	def filter_by_extension_names entities
		entities.select { |e| e[:extension_names].include?('PoliticalCandidate') || e[:extension_names].include?('ElectedRepresentative') }
	end

	def filter_by_birth_date entities, birth_date
		entities.select { |e| birth_date == e[:birth_date] }
	end

	def search_by_name name
		return [] unless name

	    Entity.search(
	      "@(name,aliases) #{name}", 
	      per_page: 10, 
	      match_mode: :extended, 
	      with: { is_deleted: false },
	      select: "*, weight() * (link_count + 1) AS link_weight",
	      order: "link_weight DESC"
	    ).select { |e| e.primary_ext == 'Person' }.collect { |e| { name: e.name, id: e.id, blurb: e.blurb, extension_names: e.extension_names, birth_date: e.start_date } }
	end

	def search_by_full_name rep
		name = rep['name']
		full, first, middle, last, suffix, nickname = name['official_full'], name['first'], name['middle'], name['last'], name['suffix'], name['nickname']

		(search_by_name full) | (search_by_name "#{first} #{middle} #{last} #{suffix}") | (search_by_name "#{nickname} #{last} #{suffix}") | (search_by_name "#{first} #{last}")
	end

	# Returns reps not in database by bioguide_id (could be in the database, but maybe their entry doesn't include their elected position)
	def unmatched_by_bgid reps
		bioguide_ids = reps.map { |rep| rep['id']['bioguide'] }
		records = ElectedRepresentative.joins(:entity).where(bioguide_id: bioguide_ids) # ActiveRecord entries
		reps.select { |rep| records.pluck(:bioguide_id).exclude? rep['id']['bioguide'] } # YAML objects
	end

	# Returns reps not in database by govtrack_id
	def unmatched_by_gtid reps
		govtrack_ids = reps.map { |rep| rep['id']['govtrack'] }
		records = ElectedRepresentative.joins(:entity).where(govtrack_id: govtrack_ids) # ActiveRecord entries
		reps.select { |rep| records.pluck(:govtrack_id).exclude? rep['id']['govtrack'] } # YAML objects
	end	

	# Returns reps not in database by crp_id
	def unmatched_by_crpid reps
		crp_ids = reps.map { |rep| rep['id']['opensecrets'] }
		records = ElectedRepresentative.joins(:entity).where(crp_id: crp_ids) # ActiveRecord entries
		reps.select { |rep| records.pluck(:crp_id).exclude? rep['id']['opensecrets'] } # YAML objects
	end	

	def unmatched_by_ids reps
		(unmatched_by_crpid @reps) & (unmatched_by_bgid @reps) & (unmatched_by_gtid @reps)
	end

	# Returns reps not in database by name (either not in the db or an alias is missing)
	# def unmatched_by_name reps
	# 	reps.select { |rep| search_by_rep(rep).count == 0 }
	# end
end