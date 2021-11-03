# frozen_string_literal: true

class OligrapherScreenshotJob < ApplicationJob
  def perform(map_id, wait_after: 0)
    require 'firefox' # in lib/ not autoloaded

    map = NetworkMap.find(map_id)

    if map.is_private?
      Rails.logger.debug "Cannot take a screenshot of a private map (#{map_id})"
      return nil
    end

    Firefox.visit(map_url(map)) do |driver|
      driver.execute_script('window.Oligrapher.instance.hideAnnotations()')
      svg = driver.execute_script('return window.Oligrapher.instance.toSvg()')
      document = Nokogiri::XML(svg)

      if svg && valid_svg?(document)
        map.update_columns(screenshot: scale_svg(document))
      else
        Rails.logger.warn "Failed to get a valid svg image for map #{map_id}"
      end

    rescue Net::ReadTimeout
      Rails.logger.warn "Net::ReadTimeout while trying to take screenshot of map #{map_id}"
    end

    sleep wait_after
  end

  private

  # Nokogiri::XML::Document --> String
  def scale_svg(document)
    document.root['height'] = '161px'
    document.root['width'] = '280px'
    document.to_s
  end

  # Nokogiri::XML::Document --> Boolean
  def valid_svg?(document)
    document.errors.length.zero? && document.root.name == 'svg'
  end

  def map_url(map)
    LittleSis::Application.routes.url_helpers.oligrapher_url(map)
  end
end
