# frozen_string_literal: true

# Shared helper functions between MapsController and OligrapherController
module MapsHelper
  def save_and_render(map)
    if map.validate
      map.save!
      render json: map
    else
      render json: map.errors, status: :bad_request
    end
  end

  def set_map
    @map = NetworkMap.find(params[:id])
  end

  def is_owner
    return false unless current_user
    return true if current_user.admin?

    @map.user_id == current_user.id
  end

  def check_private_access
    if @map.is_private && !@map.can_edit?(current_user)
      unless params[:secret] && params[:secret] == @map.secret
        raise Exceptions::PermissionError
      end
    end
  end

  def check_owner
    check_permission 'editor'

    raise Exceptions::PermissionError unless is_owner
  end

  def check_editor
    check_permission 'editor'

    raise Exceptions::PermissionError unless @map.can_edit?(current_user)
  end
end
