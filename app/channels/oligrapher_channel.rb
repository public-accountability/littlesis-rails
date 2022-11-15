class OligrapherChannel < ApplicationCable::Channel
  def subscribed
    map = NetworkMap.find(params[:id])
    if map.can_edit?(current_user)
      stream_for map
      lock = OligrapherLockService.new(map: map, current_user: current_user)
      lock.lock! unless lock.locked?
      broadcast_to(map, { lock: lock.as_json })
    else
      reject_unauthorized_connection
    end
  end

  def unsubscribed
    release
  end

  def takeover
    map = NetworkMap.find(params[:id])
    if map.user == current_user # only owners can takeover
      lock = OligrapherLockService.new(map: map, current_user: current_user)
      lock.lock!
      broadcast_to(map, { lock: lock.as_json })
    end
  end

  def release
    map = NetworkMap.find(params[:id])
    lock = OligrapherLockService.new(map: map, current_user: current_user)
    if lock.user_has_lock?
      lock.release!
      broadcast_to(map, { lock: lock.as_json })
    end
  end

  def lock
    map = NetworkMap.find(params[:id])
    if map.can_edit?(current_user)
      lock = OligrapherLockService.new(map: map, current_user: current_user)
      lock.lock!
      broadcast_to(map, { lock: lock.as_json })
    end
  end
end
