# frozen_string_literal: true

class OligrapherScreenshotSchedulingJob < ApplicationJob
  def perform(type)
    case type
    when :recent
      NetworkMap.where(is_private: false).where('updated_at >= ?', 1.day.ago).limit(100).each do |map|
        OligrapherScreenshotJob.perform_later(map.id)
      end
    when :missing
      NetworkMap.where(is_private: false, screenshot: nil).order('updated_at desc').limit(250).each do |map|
        OligrapherScreenshotJob.perform_later(map.id)
      end
    else
      raise ArgumentError
    end
  end
end
