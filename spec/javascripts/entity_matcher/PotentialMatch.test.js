import React from 'react';
import { shallow, render } from 'enzyme';

import PotentialMatch from 'packs/entity_matcher/components/PotentialMatch';

import { jPollock } from './fixtures';

describe('Potential Match', () => {
  const wrapper = shallow(<PotentialMatch match={jPollock} />);
  const staticRender = render(<PotentialMatch match={jPollock} />);

  test('shows image', () => {
    expect(staticRender.find('img').length).toEqual(1);
  });

  describe('Entity Info', () => {
    test('shows Entity Name with link', () => {
      expect(staticRender.find('a').length).toEqual(1);
      expect(staticRender.find('a')[0].attribs.href).toEqual(jPollock.entity.url);
      expect(staticRender.find('a')[0].attribs.href).toEqual(jPollock.entity.url);
      expect(staticRender.find('a').text()).toEqual(jPollock.name);
    });

    test('shows blurb', () => {
      expect(staticRender.find('.potential-match-entity-blurb').text()).toEqual(jPollock.entity.blub);
    });
  });
  
  describe('Buttons', () => {
    test.todo('shows match button');
    test.todo('shows ignore button');
  });
});
