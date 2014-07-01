class TwitterQueue
  QUEUE_PATH = 'data/twitter_queue.txt'

  def self.generate
    ids = Entity.select("entity.id, COUNT(entity.id) AS links")
      .joins("LEFT JOIN link ON (link.entity1_id = entity.id AND link.category_id = 1)")
      .joins("LEFT JOIN external_key ON (external_key.entity_id = entity.id AND external_key.domain_id = #{Domain::TWITTER_ID})")
      .where("external_key.external_id IS NULL")
      .where("entity.primary_ext = ?", "Person")
      .where("entity.blurb IS NOT NULL")
      .group("entity.id")
      .having("links >= 5")
      .map(&:id)

    write_ids(ids)
    ids
  end

  def self.write_ids(ids)
    File.open(QUEUE_PATH, 'w+') { |file| file.write(ids.join("\n")) }
  end

  def self.entity_ids
    File.open(QUEUE_PATH, 'r').read.split("\n").map(&:to_i)
  end

  def self.entities
    Entity.where(id: entity_ids)
  end

  def self.random_entity_id
    ids = entity_ids
    ids[rand(ids.count)]
  end

  def self.random_entity
    Entity.where(id: random_entity_id).first
  end

  def self.remove_entity_id(id)
    ids = entity_ids
    ids.delete(id.to_i)

    write_ids(ids)
  end
end
