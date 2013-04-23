APP_CONFIG = YAML.load(ERB.new(File.new("#{Dir.getwd}/config/lilsis.yml").read).result)[Rails.env]

