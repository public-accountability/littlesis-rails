module UsersHelper
	def user_link(user)
		link_to user.public_name, user
	end

	def user_image(user)
		link_to(content_tag(:div, " ", class: "user_image", style: "background-image: url('#{user.image_url('profile')}');"), user_path(user))
	end
end
