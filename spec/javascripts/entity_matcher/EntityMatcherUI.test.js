import React from 'react';
import { shallow } from 'enzyme';

jest.mock('packs/entity_matcher/api_client',
	  () => ({
	    "retriveDatasetRow": jest.fn(),
	    "retrivePotentialMatches": jest.fn()
	  }));

import { retriveDatasetRow } from 'packs/entity_matcher/api_client';

import * as actions from 'packs/entity_matcher/actions';
import EntityMatcherUI from 'packs/entity_matcher/EntityMatcherUI';

import ApiError from 'packs/entity_matcher/components/ApiError';
import DatasetItemHeader from 'packs/entity_matcher/components/DatasetItemHeader';
import DatasetItemInfo from 'packs/entity_matcher/components/DatasetItemInfo';
import LoadingSpinner from 'packs/entity_matcher/components/LoadingSpinner';
import PotentialMatches from 'packs/entity_matcher/components/PotentialMatches';

describe('EntityMatcherUI', () => {
  const testDatasetFields = ["one", "two"];
  
  
  describe('mounting', () => {
    test('sets default state', () => {
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>, { disableLifecycleMethods: true });

      expect(wrapper.state()).toEqual({
	"itemId": 123,
	"itemInfo": null,
	"itemInfoStatus": null,
	"matches": null,
	"matchesStatus": null,
	"datasetFields": testDatasetFields
      });
    });

    test('calls loadItemInfo after mounting', () => {
      actions.loadItemInfo = jest.fn();
      actions.loadMatches = jest.fn();
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>);
      expect(actions.loadItemInfo).toHaveBeenCalledTimes(1);
      actions.loadItemInfo.mockRestore();
      actions.loadMatches.mockRestore();
    });
  });

  describe('updateState', () => {
    test('recursively merges objects', () => {
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>);
      wrapper.instance().updateState({ itemInfo: { a: { b: 'b', c: 'c' } }});
      expect(wrapper.state().itemInfo).toEqual({ a: { b: 'b', c: 'c' } });
      wrapper.instance().updateState({ itemInfo: { a: { c: 'cc' } }});
      expect(wrapper.state().itemInfo).toEqual({ a: { b: 'b', c: 'cc' } });
    });

    test('can be called with two arguments: key, value', () => {
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>);
      expect(wrapper.state().itemInfo).toEqual(null);
      wrapper.instance().updateState("itemInfo", { a: "a" });
      expect(wrapper.state().itemInfo).toEqual({ a: "a" });
    });
  });

  describe('Loading itemInfo', () => {
    var wrapper;
    retriveDatasetRow.mockImplementation( () => Promise.resolve({"one": "foo", "two": "bar"}) );
    
    beforeEach(() => {
      wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={2}/>);
    });
      
    test('shows loading spinner while it is loaded', () => {
      wrapper.setState({"itemInfoStatus": "LOADING" });
      expect(wrapper.find(LoadingSpinner).exists()).toBe(true);
    });
    
    test('hides loading spinner after it is loading', () => {
      wrapper.setState({"itemInfoStatus": "COMPLETE" });
      expect(wrapper.find(LoadingSpinner).exists()).toBe(false);
    });
    
    test('shows itemInfo after loading', () => {
      wrapper.setState({"itemInfoStatus": "LOADING" });
      expect(wrapper.find(DatasetItemInfo).exists()).toBe(false);
      wrapper.setState({"itemInfoStatus": "COMPLETE" });
      expect(wrapper.find(DatasetItemInfo).exists()).toBe(true);
    });
    
    test('shows LoadingError if error occurs', () => {
      wrapper.setState({"itemInfoStatus": "LOADING" });
      expect(wrapper.find(ApiError).exists()).toBe(false);
      wrapper.setState({"itemInfoStatus": "ERROR" });
      expect(wrapper.find(ApiError).exists()).toBe(true);
    });
  });

});
