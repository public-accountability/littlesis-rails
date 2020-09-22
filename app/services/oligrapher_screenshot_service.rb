# frozen_string_literal: true

class OligrapherScreenshotService
  HEIGHT = '161px'
  WIDTH = '280px'

  def self.run(map)
    if map.is_private?
      Rails.logger.debug "Cannot take a screenshot of a private map (#{map.id})"
      return nil
    end

    Firefox.visit(map_url(map)) do |driver|
      driver.execute_script('window.oli.hideAnnotations()')
      svg = driver.execute_script('return window.oli.toSvg()')
      document = Nokogiri::XML(svg)

      if svg && valid_svg?(document)
        map.update!(screenshot: scale_svg(document))
      else
        Rails.logger.info "Failed to get a valid svg image for map #{map.id}"
      end
    end
  end

  # Nokogiri::XML::Document --> String
  def self.scale_svg(document)
    document.root['height'] = HEIGHT
    document.root['width'] = WIDTH
    document.to_s
  end

  # Nokogiri::XML::Document --> Boolean
  def self.valid_svg?(document)
    document.errors.length.zero? && document.root.name == 'svg'
  end

  def self.map_url(map)
    Lilsis::Application.routes.url_helpers.oligrapher_url(map)
  end

  private_class_method :scale_svg, :valid_svg?, :map_url
end
