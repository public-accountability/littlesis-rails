import React from 'react';
import { shallow } from 'enzyme';

jest.mock('packs/entity_matcher/api_client',
	  () => ({ retriveDatasetRow: jest.fn() }));

import { retriveDatasetRow } from 'packs/entity_matcher/api_client';

import * as actions from 'packs/entity_matcher/actions';
import EntityMatcherUI from 'packs/entity_matcher/EntityMatcherUI';


describe('EntityMatcherUI', () => {
  const testDatasetFields = ["one", "two"];
  
  retriveDatasetRow.mockImplementation( () => {
    return Promise.resolve({"one": "foo", "two": "bar"});
  });

  const wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={2}/>);

  describe('mounting', () => {
    test('sets default state', () =>{
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>, { disableLifecycleMethods: true });

      expect(wrapper.state()).toEqual({
	"itemId": 123,
	"itemInfo": null,
	"itemInfoStatus": null,
	"datasetFields": testDatasetFields
      });
      
    });

    test('calls loadItemInfo after mounting', () => {
      actions.loadItemInfo = jest.fn();
      let wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={123}/>);
      expect(actions.loadItemInfo).toHaveBeenCalledTimes(1);
      actions.loadItemInfo.mockRestore();
    });
  });

  describe('updateState', () => {
    test.todo('recursively merges objects');
    test.todo('can be called with two arguments: key, value');
  });

  describe('Loading itemInfo', () => {
    test.todo('shows loading spinner while it is loaded');
    test.todo('hides loading spinner after it is loading');
    test.todo('shows itemInfo after loading');
    test.todo('shows LoadingError if error occurs');
  });

});
