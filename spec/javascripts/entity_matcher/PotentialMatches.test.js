import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';
import LoadingSpinner from 'packs/entity_matcher/components/LoadingSpinner';
import PotentialMatchesHeader from 'packs/entity_matcher/components/PotentialMatchesHeader';
import PotentialMatchesSearch from 'packs/entity_matcher/components/PotentialMatchesSearch';
import PotentialMatchesList from 'packs/entity_matcher/components/PotentialMatchesList';
import NewEntityForm from 'packs/entity_matcher/components/NewEntityForm';
import CreateNewEntityButton from 'packs/entity_matcher/components/CreateNewEntityButton';

import { exampleMatch, exampleItemInfo } from './fixtures';

describe('PotentialMatches', () => {
    
  test('has div with correct id', () => {
    const wrapper = shallow(<PotentialMatches ignoreMatch={jest.fn()} doMatch={jest.fn()} itemId={1} itemInfo={exampleItemInfo} />);
    expect(wrapper.find('div#potential-matches').exists()).toBe(true);
  });

  test('showing load div when loading', () => {
    const wrapper = shallow(<PotentialMatches matchesStatus="LOADING" itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(LoadingSpinner).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesHeader).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(false);
  });

  test('shows search when there are no matches', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(LoadingSpinner).exists()).toBe(false);
    expect(wrapper.find(PotentialMatchesHeader).exists()).toBe(true);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(true);
  });

  test('shows search when there are matches', () => {
    const matches = { "automatchable": false, "results": [exampleMatch] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(PotentialMatchesSearch).exists()).toBe(true);
  });

  test('shows matches list when there are matches', () => {
    const matches = { "automatchable": false, "results": [exampleMatch] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(PotentialMatchesList).exists()).toBe(true);
  });

  test('hides matches list when there are no matches', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(PotentialMatchesList).exists()).toBe(false);
  });

  test('hides new entity form by default', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(NewEntityForm).exists()).toBe(false);
  });

  test('shows create new entity button', () => {
    const matches = { "automatchable": false, "results": [] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={jest.fn()} itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(CreateNewEntityButton).exists()).toBe(true);
  });

  test('Clicking on create new entity link loads new entity form', () => {
    const matches = { "automatchable": false, "results": [exampleMatch] };
    const wrapper = shallow(<PotentialMatches matchesStatus="COMPLETE" matches={matches} itemId={1} doMatch={ (itemId, entity) => jest.fn() } itemInfo={exampleItemInfo}/>);
    expect(wrapper.find(CreateNewEntityButton).exists()).toBe(true);
    expect(wrapper.find(NewEntityForm).exists()).toBe(false);
    wrapper.find(CreateNewEntityButton).shallow().find('a').simulate('click');
    expect(wrapper.find(NewEntityForm).exists()).toBe(true);
    expect(wrapper.find(CreateNewEntityButton).exists()).toBe(false);
    expect(wrapper.find(PotentialMatchesList).exists()).toBe(false);
  });
  
});
