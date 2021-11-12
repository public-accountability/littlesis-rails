# frozen_string_literal: true

class OligrapherScreenshotJob < ApplicationJob
  def perform(map_id)
    map = NetworkMap.find(map_id)
    OligrapherScreenshotService.run(map)
  end
end
