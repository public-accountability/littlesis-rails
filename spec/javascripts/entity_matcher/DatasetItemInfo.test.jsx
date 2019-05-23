import React from 'react';
import { render } from 'enzyme';

import DatasetItemInfo from 'packs/entity_matcher/components/DatasetItemInfo';

describe('DatasetItemInfo', () => {

  const rowData = { "crd_number": 165306,
                    "name": "Example",
                    "class": "ExternalDataset::IapdAdvisor",
                    "data": [{
                      "name": "Example",
                      "dba_name": "Example LLC",
                      "crd_number": "123456",
                      "sec_file_number": "xyz",
                      "assets_under_management": 1000000,
                      "total_number_of_accounts": 3006,
                      "filing_id": 1213456,
                      "date_submitted": "04/30/2018 12:28:46 PM",
                      "filename": "IA_ADV_Base_A_20180401_20180630.csv"
                    }]
                  };

  const itemInfo = { "match_data": null,
                     "primary_ext": "org",
                     "entity_id": null,
                     "dataset_key": "165306",
                     "id": 132531,
                     "name": "iapd",
                     "row_data": rowData };
    
  
  const html = render(<DatasetItemInfo itemInfo={itemInfo} />);
  
  it('has 5 title spans', () => expect(html.find('.item-info-title').length).toEqual(5));
  it('has 5 value spans', () => expect(html.find('.item-info-value').length).toEqual(5));
  it('has foo and bar, but not baz', () => {
    expect(html.text()).toMatch(/Example/);
    expect(html.text()).toMatch(/\$1,000,000/);
    expect(html.text()).not.toMatch(/baz/);
  });
});
