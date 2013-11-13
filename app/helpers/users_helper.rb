module UsersHelper
	def user_link(user)
		link_to user.public_name, user
	end
end
