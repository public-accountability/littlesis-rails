# frozen_string_literal: true

require 'tempfile'

module OligrapherScreenshotService
  def self.run(map)
    if map.is_private?
      Rails.logger.debug "Cannot take a screenshot of a private map (#{map.id})"
      return nil
    end

    tempfile = Tempfile.new

    if system("#{Rails.root.join('lib/scripts/oligrapher_screenshot.js')} #{map_url(map)} > #{tempfile.path}")
      svg = tempfile.read.strip

      if valid_svg?(svg)
        map.update_columns(screenshot: reset_dimensions(svg))
      else
        Rails.logger.warn "Failed to get a valid svg image (NetworkMap\##{map.id})"
      end
    else
      Rails.logger.warn "oligrapher_screenshot.js failed (NetworkMap\##{map.id})"
    end

    tempfile.close
    tempfile.unlink
    map
  end

  # remove height & width attributes so svg can be scaled
  def self.reset_dimensions(svg)
    document = Nokogiri::XML(svg)
    document.root['height'] = nil
    document.root['width'] = nil
    document.to_s
  end

  def self.valid_svg?(svg)
    return false if svg.blank?

    document = Nokogiri::XML(svg)
    document.errors.length.zero? && document.root&.name == 'svg'
  end

  def self.map_url(map)
    LittleSis::Application.routes.url_helpers.oligrapher_url(map)
  end

  private_class_method :reset_dimensions, :valid_svg?, :map_url
end