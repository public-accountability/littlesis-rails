import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatchesList from 'packs/entity_matcher/components/PotentialMatchesList';
import PotentialMatch from 'packs/entity_matcher/components/PotentialMatch';

import { exampleMatch, jPollock } from './fixtures';

describe('PotentialMatchesList', () => {

  test('Shows 2 matches', () => {
    const matches = { "automatchable": false, "results": [exampleMatch, jPollock] };
    const wrapper = shallow(<PotentialMatchesList matches={matches} ignoreMatch={jest.fn()} itemId={1} doMatch={jest.fn()}/>);
    expect(wrapper.find(PotentialMatch).length).toEqual(2);
  });

});
