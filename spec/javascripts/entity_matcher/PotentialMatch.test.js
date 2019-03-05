import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatch from 'packs/entity_matcher/components/PotentialMatch';

import { jPollock } from './fixtures';

describe('Potential Match', () => {
  const wrapper = shallow(<PotentialMatch match={jPollock} />);
  
  test.todo('shows image');

  describe('Entity Info', () => {
    test.todo('shows Entity Name with link');
    test.todo('shows blurb');
    test.todo('shows ');
  });
  
  describe('Buttons', () => {
    test.todo('shows match button');
    test.todo('shows ignore button');
  });
});
