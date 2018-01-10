require 'roo'

module Cmp
  class ExcelSheet
    attr_reader :xlsx, :sheet
    delegate :parse, :to => :sheet

    def initialize(filepath, sheet = 0)
      @xlsx = Roo::Spreadsheet.open(filepath)
      @sheet = @xlsx.sheet(sheet)
    end
  end
end
