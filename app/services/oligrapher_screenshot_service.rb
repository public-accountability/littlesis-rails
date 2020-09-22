# frozen_string_literal: true

class OligrapherScreenshotService
  def self.run(map)
    Firefox.visit(map_url(map)) do |driver|
      svg = driver.execute_script('return window.oli.toSvg()')
      if svg && valid_svg?(svg)
        map.update!(screenshot: svg)
      else
        Rails.logger.info "Failed to get a valid svg image for map #{map.id}"
      end
    end
  end

  def self.valid_svg?(svg)
    true
  end

  def self.map_url(map)
    Lilsis::Application.routes.url_helpers.oligrapher_url(map)
  end
end
