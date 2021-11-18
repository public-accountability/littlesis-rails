# frozen_string_literal: true

class OligrapherScreenshotJob < ApplicationJob
  def perform(map_id)
    NetworkMap.find(map_id).take_screenshot
  end
end
