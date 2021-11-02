# frozen_string_literal: true

class OligrapherScreenshotSchedulingJob < ApplicationJob
  def perform(type, hours: 25)
    case type
    when :recent
      NetworkMap.where(is_private: false).where('updated_at > ?', hours.hours.ago).each do |map|
        OligrapherScreenshotJob.perform_later(map.id, wait_after: 1)
      end
    when :missing
      NetworkMap.where(is_private: false, screenshot: nil).find_each(batch_size: 100).each do |map|
        OligrapherScreenshotJob.perform_later(map.id, wait_after: 1)
      end
    else
      raise ArgumentError
    end
  end
end
