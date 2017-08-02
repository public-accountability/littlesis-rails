class Tag
  TAGS = YAML.load(File.open(Rails.root.join(APP_CONFIG["tags_path"]))).map do |h|
    ActiveSupport::HashWithIndifferentAccess.new(h)
  end

  def self.all
    TAGS
  end
end
