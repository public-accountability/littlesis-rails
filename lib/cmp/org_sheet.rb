module Cmp
  class OrgSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpid: 'CMPID_ORGL',
      cmpmnemonic: 'CMPMnemonic',
      cmpname: 'CMPName',
      orgtype: 'OrgType_a',
      orgtype_code: 'OrgType_n',
      city: 'City',
      province: 'Province-State_US-Can',
      latitude: 'Latitude',
      longitude: 'Longitude',
      revenue: 'Revenue2015_CombinedEstimates',
      website: 'Websiteaddress_2016',
      status: 'Status_2016'
    }.freeze

    def to_a
      parse(**HEADER_MAP)
    end
  end
end
