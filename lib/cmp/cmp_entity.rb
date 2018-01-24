module Cmp
  class CmpEntity
    attr_reader :attributes

    def initialize(attrs)
      @attributes = ActiveSupport::HashWithIndifferentAccess.new(attrs)
    end

    def cmpid
      attributes['cmpid']
    end

    # join table between CMP IDS and LittleSis Entity
    # Fields:
    #  - id (int)
    #  - cmp_id (int)
    #  - entity_id (int)
    #  - type ? (org/person)
  end
end
