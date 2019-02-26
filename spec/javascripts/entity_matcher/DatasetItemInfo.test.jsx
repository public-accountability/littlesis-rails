import React from 'react';
import { shallow } from 'enzyme';

import DatasetItemInfo from 'packs/entity_matcher/components/DatasetItemInfo';

describe('DatasetItemInfo', () => {
  const wrapper = shallow(<DatasetItemInfo />);
  
  it('has div with correct id', () => {
    expect(wrapper.find('div#dataset-item-info').exists()).toBe(true);
  });
});
