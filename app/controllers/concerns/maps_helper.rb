# frozen_string_literal: true

# Shared helper functions between MapsController and OligrapherController
module MapsHelper
  def set_map
    @map = NetworkMap.find(params[:id])
  end

  def is_owner
    return false unless current_user
    return true if current_user.admin?

    @map.user_id == current_user.id
  end

  def check_private_access
    raise Exceptions::PermissionError if @map.is_private && !is_owner
  end

  def check_owner
    check_permission 'editor'

    raise Exceptions::PermissionError unless is_owner
  end
end
