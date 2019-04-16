import React from 'react';
import { shallow } from 'enzyme';

import {
  EntitySearch,
  AutocompleteBox,
  AutocompleteEntity
} from 'packs/search/EntitySearch';

describe('EntitySearch', () => {
  let wrapper = shallow(<EntitySearch />);
  
  test('renders a <input>', () => {
    expect(wrapper.find('input').exists()).toBe(true);
  });
});
