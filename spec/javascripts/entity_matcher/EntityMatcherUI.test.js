import React from 'react';
import { shallow } from 'enzyme';

import actions from 'packs/entity_matcher/actions';
import EntityMatcherUI from 'packs/entity_matcher/EntityMatcherUI';

import { Store } from '@public-accountability/simplestore';

import ApiError from 'packs/entity_matcher/components/ApiError';
import DatasetItemHeader from 'packs/entity_matcher/components/DatasetItemHeader';
import DatasetItemInfo from 'packs/entity_matcher/components/DatasetItemInfo';
import LoadingSpinner from 'packs/entity_matcher/components/LoadingSpinner';
import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';

jest.mock('packs/entity_matcher/actions');

describe('EntityMatcherUI', () => {
  describe('mounting', () => {
    test('calls loadItemInfo after mounting', () => {
      let mockStore = new Store({}, { itemId: 123});
      let mockActions = { loadItemInfoAndMatches: jest.fn() }
      actions.withStore.mockReturnValue(mockActions);
      let wrapper = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(mockActions.loadItemInfoAndMatches).toHaveBeenCalledTimes(1);
      actions.withStore.mockReset();
    });
  });

  describe('Loading itemInfo', () => {
    var wrapper;
    var store;

    beforeAll(()=> {
      var mockActions = { loadItemInfoAndMatches: jest.fn() }
      actions.withStore.mockReturnValue(mockActions);
    });

    afterAll(() => {
      actions.withStore.resetMock();
    });

    test('shows loading spinner while it is loaded', () => {
      let mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "LOADING" });
      let em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(LoadingSpinner).exists()).toBe(true);
    });
    
    test('hides loading spinner after it is loading', () => {
      let mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "COMPLETE" });
      let em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(LoadingSpinner).exists()).toBe(false);
    });
    
    test('shows itemInfo after loading', () => {
      let mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "LOADING" });
      let em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(DatasetItemInfo).exists()).toBe(false);
      mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "COMPLETE" });
      em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(DatasetItemInfo).exists()).toBe(true);
    });
    
    test('shows LoadingError if error occurs', () => {
      let mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "LOADING" });
      let em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(ApiError).exists()).toBe(false);
      mockStore = new Store({}, { "itemId": 123, "itemInfoStatus": "ERROR" });
      em = shallow(<EntityMatcherUI store={mockStore}/>);
      expect(em.find(ApiError).exists()).toBe(true);
    });
  });
});
