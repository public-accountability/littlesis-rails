module UsersHelper
	def user_link(user, name=nil)
		name ||= user.username
		link_to name, user_notes_path(user)
	end

	def user_image(user)
		link_to(content_tag(:div, " ", class: "user_image", style: "background-image: url('#{user.image_url('profile')}');"), user_path(user))
	end
end
