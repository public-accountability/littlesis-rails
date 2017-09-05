class Tag
  VALIDATE = lambda do |tags|
    raise ArgumentError, "Duplicate IDs exist" unless tags.map { |t| t[:id] }.uniq.length == tags.length
    tags
  end

  TAGIFY = lambda do |hash|
    ActiveSupport::HashWithIndifferentAccess.new(hash).tap do |tag|
      def tag.restricted?
        fetch(:restricted, false)
      end

      def tag.id
        fetch(:id)
      end

      def tag.permissions
        fetch(:permissions)
      end
    end
  end

  TAGS = VALIDATE.call(
    YAML.load(File.open(Rails.root.join(APP_CONFIG["tags_path"]))).map(&TAGIFY)
  ).freeze

  LOOKUP = TAGS.reduce({}) do |memo, tag|
    memo[tag[:id]] = tag
    memo[tag[:name]] = tag
    memo
  end

  # (set, set) -> hash
  def self.parse_update_actions(client_ids, server_ids)
    {
      ignore: client_ids & server_ids,
      add: client_ids - server_ids,
      remove: server_ids - client_ids
    }
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

