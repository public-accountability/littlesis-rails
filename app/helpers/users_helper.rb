# frozen_string_literal: true

module UsersHelper
  def user_link(user, name = nil)
    name ||= user.username
    link_to name, user_page_path(user)
  end

  def user_image(user)
    link_to(content_tag(:div, " ", class: "user_image", style: "background-image: url('#{user.image_path('profile')}');"), user_page_path(user))
  end

  def user_profile_image
    image_tag(@user.image_url, alt: @user.username, class: 'img-rounded')
  end

  def user_abilities(user)
    user.abilities.to_a.join(", ")
  end
end
