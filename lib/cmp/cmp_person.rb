module Cmp
  class CmpPerson < CmpEntityImporter
    ATTRIBUTE_MAP = {
      fullname: [:entity, :name]
    }.freeze
  end
end
