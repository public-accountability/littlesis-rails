class SfGuardGroup < ActiveRecord::Base
  include SingularTable	

	def create_group
		Group.where(slug: display_name).first_or_create do |group|
			group.slug = name
			group.name = display_name
			group.tagline = blurb
			group.description = description
			group.is_private = is_private
			group.default_network_id = home_network_id
			group.created_at = created_at
			group.updated_at = updated_at
		end
	end
end