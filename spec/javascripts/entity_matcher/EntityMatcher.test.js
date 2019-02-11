import React from 'react';
import { EntityMatcherUI, EntityTitle } from 'packs/entity_matcher/EntityMatcher';
import { shallow } from 'enzyme';

describe('EntityMatcher', () => {
  const wrapper = shallow(<EntityMatcherUI entityId="123" />);
  it('renders EntityTitle', () => expect(wrapper.find(EntityTitle).length).toEqual(1));
  it('sets entityId', () => expect(wrapper.state().data.get('entityId')).toEqual(123));
});
