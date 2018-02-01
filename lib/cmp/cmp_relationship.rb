# @relationships = [ relationship ]
# @person = {
#     'cmpid' -> `cmp_person`
# }
# loop through relationships
#
#   get Org viap CmpEntity
#
#   get person:
#     1) CmpEntity exists
#     2) Search for matching person
#     3) create new person
#
#   look for similar relationship)
#
#    1) look for CmpRelationship
#       if found, check for updates
#
#    2) look for similar relationships
#       if found, check for updates
#
#    3) create new relationship
#
#        also create CmpRelationship
module Cmp
  class CmpRelationship
    attr_reader :attributes
    delegate :fetch, to: :attributes

    def initialize(attrs)
      @attributes = LsHash.new(attrs)
      # @org = CmpEntity.find_by(cmp_id: fetch(:cmp_org_id))&.entity
    end

    def cmp_person
      Cmp::Datasets.people.fetch fetch(:cmp_person_id)
    end
  end
end
