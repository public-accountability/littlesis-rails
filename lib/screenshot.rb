class Screenshot

  def self.take(url, path)
    status = true
    
    Selenium::WebDriver::Firefox::Binary.path= "/usr/bin/firefox"

    Headless.ly do
      begin
        driver = Selenium::WebDriver.for :firefox
        driver.manage.window.size = Selenium::WebDriver::Dimension.new(960, 550)
        driver.get url
        # hide annotations
        driver.execute_script("document.getElementById('oligrapherGraphAnnotation') ? (document.getElementById('oligrapherGraphAnnotation').style.display = 'none') : null;")
        driver.save_screenshot(path)
      rescue
        status = false
      ensure
        driver.quit
      end
    end

    return status
  end
  
  def self.resize_map_thumbnail(path)
    cmd = "mogrify -crop 960x550+60+40 #{path}"
    `#{cmd}`
  end

end
