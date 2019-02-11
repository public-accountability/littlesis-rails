import React from 'react';
import { EntityMatcherUI } from 'packs/entity_matcher/EntityMatcherUI';
import { shallow, mount, render } from 'enzyme';

describe('EntityMatcher', () => {
  it('renders h1', () => {
    const wrapper = shallow(<EntityMatcherUI />);
    expect(wrapper.find('h1').length).toEqual(1);
  });
});
