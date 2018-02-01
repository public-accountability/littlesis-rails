module Cmp
  class CmpPerson < CmpEntityImporter
    ATTRIBUTE_MAP = {
      fullname: [:entity, :name]
    }.freeze

    def attributes_with_matches
      attributes.merge(
        Array.new(2) { |n| potential_matches[n] }
          .map.with_index(1) { |entity, n| format_match(entity, n) }
          .each_with_object({}) { |match, obj| obj.merge!(match) }
      )
    end

    def potential_matches
      @_potential_matches ||=
        EntityMatch.new(name: entity_name, primary_ext: 'Person', cmpid: cmpid).search_results
    end

    private

    def entity_name
      name = "#{fetch(:firstname)} "
      name << "#{fetch(:middlename)} " if fetch(:middlename, nil).present?
      name << fetch(:lastname)
      name
    end

    def format_match(entity, n)
      {
        "match#{n}_name" => entity.present? ? "#{entity.name} (#{entity.id})" : '',
        "match#{n}_blurb" => entity&.blurb,
        "match#{n}_url" => entity.present? ? entity_url(entity) : ''
      }
    end
  end
end
