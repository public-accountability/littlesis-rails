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

  LOOKUP = TAGS.reduce({}) do |memo, tag|
    memo[tag[:id]] = tag
    memo[tag[:name]] = tag
    memo
  end

  def self.find(name_or_id)
    LOOKUP[name_or_id]
  end

  def self.find!(name_or_id)
    tag = find(name_or_id)
    raise NonexistentTagError, "#{name_or_id} is not a Tag!" if tag.nil?
    tag
  end

  def self.all
    TAGS
  end

  class NonexistentTagError < StandardError; end
end
