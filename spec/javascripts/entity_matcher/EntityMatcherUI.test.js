import React from 'react';
import { shallow } from 'enzyme';

jest.mock('packs/entity_matcher/api_client',
	  () => ({ retriveDatasetRow: jest.fn() }));

import { retriveDatasetRow } from 'packs/entity_matcher/api_client';

import EntityMatcherUI from 'packs/entity_matcher/EntityMatcherUI';


describe('EntityMatcherUI', () => {
  const testDatasetFields = ["one", "two"];
  
  retriveDatasetRow.mockImplementation( () => {
    return Promise.resolve({"one": "foo", "two": "bar"});
  });

  const wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={2}/>);

  describe('mounting', () => {
    test.todo('sets default state');
    test.todo('calls loadItemInfo after mounting');
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
