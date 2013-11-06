module ApplicationHelper

	def centered_content(id=nil, &block)
		content_id = (id.nil? ? nil : id.to_s + "_content")
		str = content_tag("div", 
			content_tag("div", 
				"\n" + capture(&block) + "\n", 
				{ :class => "centered_content", :id => content_id },
				false
			), 
			{ :class => "centered", :id => id },
			false
		)			
		raw str
	end
end
