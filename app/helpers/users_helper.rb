module UsersHelper
	def user_link(user, name=nil)
		name ||= user.username
		link_to name, user.legacy_url
	end

  def user_at_link(user, name=nil)
    name ||= '@' + user.username
    link_to name, user.legacy_url
  end

	def user_image(user)
		link_to(content_tag(:div, " ", class: "user_image", style: "background-image: url('#{user.image_path('profile')}');"), user.legacy_url)
	end

	def user_profile_image
    	image_tag(@user.image_url, alt: @user.username, class: 'img-rounded')
  	end
end
