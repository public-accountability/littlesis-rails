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
    # return true if current_user.admin?
    current_user.present? && @map.user_id == current_user.id
  end

  def check_owner
    current_user.role.include? :create_map
    raise Exceptions::PermissionError unless is_owner
  end

  def can_view_if_private?
    @map.can_edit?(current_user) || @map.has_pending_editor?(current_user)
  end

  def check_private_access
    if @map.is_private && !can_view_if_private?
      unless params[:secret] && params[:secret] == @map.secret
        raise Exceptions::PermissionError
      end
    end
  end

  def check_editor
    raise Exceptions::PermissionError unless @map.can_edit?(current_user)
  end

  def map_not_found
    render 'errors/not_found', status: :not_found, layout: 'application'
  end
end
