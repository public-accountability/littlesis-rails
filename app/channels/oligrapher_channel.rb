class OligrapherChannel < ApplicationCable::Channel
  def subscribed
    map = NetworkMap.find(params[:id])
    if map.can_edit?(current_user)
      stream_from "oligrapher_#{map.id}"
    else
      reject_unauthorized_connection
    end
  end

  # def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  # end

  def lock
    Rails.logger.debug  "OligrapherChannel lock #{current_user}"
  end
end
