class ForbesFourHundredImporter
  attr_accessor :list, :entity, :entities, :name, :rank, :image_url, :net_worth

  def initialize(list_id)
    @list = List.find(list_id)
    @forbes_lists = [4, 139, 260, 456, 846]
    @entity = nil
  end

  def import(data)
    @rank, @name, @image_url, @net_worth = data
    match_or_create_entity
    add_entity_image
    add_entity_to_list
  end

  def match_or_create_entity
    begin
      parser = NameParser.new(@name)
      @entities = EntityMatcher.by_person_name(parser.first, parser.last, parser.middle, parser.suffix, parser.nick)
      @entities = @entities.concat(EntityMatcher.by_full_name(@name))
      @entities = @entities.concat(EntityMatcher.by_full_name(@name.gsub('.', ''))).uniq(&:id)
      return @entity = @entities.first if entities.count == 1
      @entities.select! { |e| (e.lists.map(&:id) & @forbes_lists).count > 0 }
      return @entity = @entities.first if entities.count == 1
      create_entity
    rescue => e
      binding.pry
    end
  end

  def create_entity
    ext = NameParser.couple_name?(@name) ? 'Couple' : 'Person'
    if ext == 'Person'
      @entity = Entity.create(
        name: @name,
        primary_ext: ext
      )
    elsif ext == 'Couple'
      parts = @name.split(/\s/)
      last = parts.last
      firsts = parts.take(parts.count - 1).join(' ').split(/\s+&\s+/)
      binding.pry
      partners = firsts.map do |first|
        Entity.create(
          name: first + " " + last,
          primary_ext: 'Person'
        )
      end
      @entity = Entity.create_couple(@name, partners[0], partners[1])
    end
    @entity
  end

  def add_entity_image
    @entity.add_image_from_url(@image_url, true)
  end

  def add_entity_to_list
    unless @entity.lists.map(&:id).include?(@list.id)
      ListEntity.create(
        entity_id: @entity.id,
        list_id: @list.id,
        rank: @rank
      )
    end
  end
end