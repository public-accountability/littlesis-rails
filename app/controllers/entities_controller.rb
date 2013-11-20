class EntitiesController < ApplicationController
	before_filter :auth

	def search_by_name
		data = []
		q = params[:q]
		entities = Entity.search "@(name,aliases) #{q}", per_page: 10, match_mode: :extended
		data = entities.collect { |e| { value: e.name, name: e.name, id: e.id } }
		render json: data
	end	
end