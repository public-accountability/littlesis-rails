import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';
import LoadingSpinner from 'packs/entity_matcher/components/LoadingSpinner';
import PotentialMatchesHeader from 'packs/entity_matcher/components/PotentialMatchesHeader';
import PotentialMatchesSearch from 'packs/entity_matcher/components/PotentialMatchesSearch';
import PotentialMatchesList from 'packs/entity_matcher/components/PotentialMatchesList';

import { exampleMatch } from './fixtures';

describe('PotentialMatches', () => {
    
  test('has div with correct id', () => {
    const wrapper = shallow(<PotentialMatches />);
    expect(wrapper.find('div#potential-matches').exists()).toBe(true);
  });


  test('showing load div when loading', () => {
    const wrapper = shallow(<PotentialMatches matchesStatus="LOADING" />);
    expect(wrapper.find(LoadingSpinner).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesHeader).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(false);
  });

  test('shows search when there are no matches', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} />);
    expect(wrapper.find(LoadingSpinner).exists()).toBe(false);
    expect(wrapper.find(PotentialMatchesHeader).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(true);
  });

  test('shows search when there are matches', () => {
    const matches = { "automatchable": false, "results": [exampleMatch] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} />);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(true);
  });

  test('shows matches list when there are matches', () => {
    const matches = { "automatchable": false, "results": [exampleMatch] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} />);
    expect(wrapper.find(PotentialMatchesList).exists()).toBe(true);
  });

  test('hides matches list when there are no matches', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} />);
    expect(wrapper.find(PotentialMatchesList).exists()).toBe(false);
  });
  
});
