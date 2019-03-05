import React from 'react';
import { shallow } from 'enzyme';

import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';
import LoadingSpinner from 'packs/entity_matcher/components/LoadingSpinner';
import PotentialMatchesHeader from 'packs/entity_matcher/components/PotentialMatchesHeader';
import PotentialMatchesSearch from 'packs/entity_matcher/components/PotentialMatchesSearch';
import PotentialMatchesList from 'packs/entity_matcher/components/PotentialMatchesList';

describe('PotentialMatches', () => {

  const exampleMatch = {
    "entity": {
      "id": 109722,
      "name": "Joy Pollock",
      "blurb": null,
      "summary": null,
      "website": null,
      "parent_id": null,
      "primary_ext": "Person",
      "created_at": "2012-12-09T14:05:18.000Z",
      "updated_at": "2012-12-09T14:05:18.000Z",
      "start_date": null,
      "end_date": null,
      "is_current": null,
      "is_deleted": false,
      "merged_id": null,
      "link_count": 1,
      "url": "http://localhost:8080/person/109722-Joy_Pollock",
      "image_url": "/images/system/anon.png"
    },
    "values": [ "same_last_name", "mismatched_middle_name", "similar_last_name", "similar_first_name", "common_last_name" ],
    "ranking": 63,
    "automatch": false
  };
  
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
