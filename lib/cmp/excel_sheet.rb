require 'roo'

module Cmp
  class ExcelSheet
    attr_reader :xlsx, :sheet

    delegate :parse, :to => :sheet

    def initialize(filepath, sheet = 0)
      @xlsx = Roo::Spreadsheet.open(filepath)
      @sheet = @xlsx.sheet(sheet)
    end

    def to_a
      parse(**self.class.const_get(:HEADER_MAP))
    end
  end
end
