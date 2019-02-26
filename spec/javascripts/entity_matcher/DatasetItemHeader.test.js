import React from 'react';
import { shallow } from 'enzyme';

import DatasetItemHeader from 'packs/entity_matcher/components/DatasetItemHeader';

describe('DatasetItemHeader', () => {
  const wrapper = shallow(<DatasetItemHeader item_id="123" />);
  it('renders header with it', () => expect(wrapper.text()).toEqual('Unmatched Item #123'));
});
