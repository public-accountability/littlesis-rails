import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';

describe('PotentialMatches', () => {
  const wrapper = shallow(<PotentialMatches />);
  
  it('has div with correct id', () => {
    expect(wrapper.find('div#potential-matches').exists()).toBe(true);
  });
});
