module EntitiesHelper
	def entity_link(entity, name=nil, action = nil)
		name ||= entity.name
		link_to name, entity.legacy_url(action)
	end

	def tiny_entity_image(entity)
	  content_tag('div', nil, class: "entity_tiny_image", style: "background-image: url('#{image_path(entity.featured_image_url('small'))}');")
	end
end
