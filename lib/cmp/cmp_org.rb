module Cmp
  class CmpOrg < Cmp::CmpEntity
    # Mapping between cmp fields and Model/Attribute for entities
    ATTRIBUTE_MAP = {
      :cmpname => [:entity, :name],
      :cmpmnemonic => [:org, :name_nick],
      :revenue => [ :org, :revenue ],
      :website  => [ :entity, :website ],
      :city => [ :address, :city ],
      :latitude => [:address, :latitude ],
      :longitude => [:address, :longitude ]
    }.freeze

    def entity_match
      return @_entity_match if defined?(@_entity_match)
      @_entity_match =  Cmp::EntityMatch.new name: @attributes.fetch(:cmpname), primary_ext: 'Org'
    end
    
    def to_h
      @attributes.merge({
        potential_matches: entity_match.count,
        url: entity_match.empty? ? "" : entity_url(entity_match.first)
      })
    end
  end
end
