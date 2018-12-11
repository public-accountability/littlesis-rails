# frozen_string_literal: true

class UserPresenter < SimpleDelegator
  attr_internal :current_user

  def initialize(user, current_user: nil)
    super(user)
    @_current_user = current_user
  end

  # helper to limit access to users viewing their own page and admins
  # certain sections of the user page such as the permissions section
  # are currently limited to admins and users's themselves
  def show_private?
    current_user_is_user || (current_user.present? && current_user.admin?)
  end

  def groups
    return @_groups if defined?(@_groups)
    @_groups = super().order(:name)
  end

  def lists
    super().order("created_at DESC, id DESC")
  end

  # string ---> string
  def ability_display(ability)
    abilities.include?(ability) ? 'Yes' : 'No'
  end

  def member_since
    "member since #{created_at.strftime('%B %Y')}"
  end

  # If the current user is viewing their own profile page
  # all maps will shown. Anyone else will not be able to see their private maps
  def maps
    return @_maps if defined?(@_maps)
    where = current_user_is_user ? {} : { is_private: false }
    @_maps = network_maps.where(where).order("updated_at DESC").limit(75)
  end

  private

  def current_user_is_user
    user == current_user
  end

  def user
    __getobj__
  end
end
