class Tag
  VALIDATE = lambda do |tags|
    raise ArgumentError, "Duplicate IDs exist" unless tags.map { |t| t[:id] }.uniq.length == tags.length
    tags
  end

  TAGS = VALIDATE.call(
    YAML.load(File.open(Rails.root.join(APP_CONFIG["tags_path"]))).map do |h|
      ActiveSupport::HashWithIndifferentAccess.new(h)
    end
  )
  

  def self.all
    TAGS
  end

  def self.by_name(name)
    Tag.all.select{ |t| t[:name] == name }.first
  end
end
