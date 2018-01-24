module Cmp
  class OrgSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpid: 'CMPID_ORGL',
      cmpmnemonic: 'CMPMnemonic',
      cmpname: 'CMPName',
      orgtype: 'OrgType_a',
      orgtype_code: 'OrgType_n',
      city: 'City',
      country: 'Country',
      province: 'Province-State_US-Can',
      latitude: 'Latitude',
      longitude: 'Longitude',
      revenue: 'Revenue2015_CombinedEstimates',
      website: 'Websiteaddress_2016',
      status: 'Status_2016',
      ticker: 'Tickersymbol_2016',
      industry_name: 'Industry7cat_a',
      industry_number: 'Industry7cat_n'
    }.freeze
  end
end
