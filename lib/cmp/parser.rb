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

  class OrgSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpid: 'CMPID_ORGL',
      cmpmnemonic: 'CMPMnemonic',
      cmpname: 'CMPName',
      orgtype: 'OrgType_a'
    }.freeze

    def to_a
      parse(**HEADER_MAP)
    end
  end
end
