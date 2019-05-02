import React from 'react';
import { shallow, render } from 'enzyme';

import PotentialMatch from 'packs/entity_matcher/components/PotentialMatch';

import { jPollock } from './fixtures';

describe('Potential Match', () => {
  const wrapper = shallow(<PotentialMatch match={jPollock} ignoreMatch={jest.fn()}  doMatch={jest.fn()} itemId={1} />);
  const staticRender = render(<PotentialMatch match={jPollock} ignoreMatch={jest.fn()} doMatch={jest.fn()} itemId={1} />);

  // test('shows image', () => {
  //   expect(staticRender.find('img').length).toEqual(1);
  // });

  describe('Entity Info', () => {
    test('shows Entity Name with link', () => {
      expect(staticRender.find('.potential-match-entity a').length).toEqual(1);
      expect(staticRender.find('.potential-match-entity a')[0].attribs.href).toEqual(jPollock.entity.url);
      expect(staticRender.find('.potential-match-entity a')[0].attribs.href).toEqual(jPollock.entity.url);
      expect(staticRender.find('.potential-match-entity a').text()).toEqual(jPollock.entity.name);
    });

    test('shows blurb', () => {
      expect(staticRender.find('.potential-match-entity-blurb').text()).toEqual(jPollock.entity.blurb);
    });
  });
  
  describe('Buttons', () => {
    test('shows 1 buttons', () => {
      expect(staticRender.find('.potential-match-buttons a').length).toEqual(1);
    });

    test.todo('shows ignore button');
  });
});
