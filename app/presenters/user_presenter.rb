# frozen_string_literal: true

class UserPresenter < SimpleDelegator
  attr_internal :current_user

  def initialize(user, current_user: nil)
    super(user)
    @_current_user = current_user
  end

  # Only the user's themselves and admins can view
  # certain sections of the profile page such as the permission section
  def show_private?
    user == current_user || (current_user.present? && current_user.admin?)
  end

  def groups
    return @_groups if defined?(@_groups)
    @_groups = super().order(:name)
  end

  def lists
    super().order("created_at DESC, id DESC")
  end

  def recent_updates
    edited_entities.includes(last_user: :user).order("updated_at DESC").limit(10)
  end

  # string ---> string
  def permisison_display(p)
    permissions.include?(p) ? "Yes" : "No"
  end

  def permissions
    return @_permissions if defined?(@_permissions)
    @_permissions = super().instance_variable_get(:@sf_permissions)
  end

  def maps
    network_maps.order("created_at DESC, id DESC")
  end

  private

  def user
    __getobj__
  end
end
