import React from 'react';

import {
  EntitySearch,
  AutocompleteBox,
  AutocompleteEntity
} from 'packs/search/EntitySearch';

describe('EntitySearch', () => {
  let wrapper = enzyme.shallow(<EntitySearch />);
  
  it('renders an <input>', () => {
    expect(wrapper.find('input').exists()).to.be.true;
  });
});
