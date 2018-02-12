class EntityVersionPresenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper

  def user_link
    return 'System' if user.nil?
    link_to(user.username, "/users/#{user.username}")
  end
end
