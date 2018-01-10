module Cmp
  class CmpPerson < Cmp::CmpEntity
    def name
      "#{@attributes.fetch(:firstname)} #{@attributes.fetch(:middlename)} #{@attributes.fetch(:lastname)}"
    end

    def entity_match
      return @_entity_match if defined?(@_entity_match)
      @_entity_match = Cmp::EntityMatch.new name: name, primary_ext: 'Person'
    end

    def to_h
      @attributes.merge(
        potential_matches: entity_match.count,
        url1: entity_match.empty? ? "" : entity_url(entity_match.first),
        url2: entity_match.count < 1 ? "" : entity_url(entity_match.second)
      )
    end

    private

    def entity_url(entity)
      "https://littlesis.org#{Rails.application.routes.url_helpers.entity_path(entity).gsub('entities', 'person')}"
    end
  end
end
