import React from 'react';
import { shallow } from 'enzyme';

import EntityMatcherUI from 'packs/entity_matcher/EntityMatcherUI';

describe('EntityMatcherUI', () => {
  const testDatasetFields = ["one", "two"];
  const wrapper = shallow(<EntityMatcherUI datasetFields={testDatasetFields} itemId={2}/>);

  describe('mounting', () => {
    it('sets default state');
    it('calls loadItemInfo after mounting');
  });

  describe('updateState', () => {
    it('recursively merges objects');
    it('can be called with two arguments: key, value');
  });

  describe('Loading itemInfo', () => {
    it('shows loading spinner while it is loaded');
    it('hides loading spinner after it is loading');
    it('shows itemInfo after loading');
    it('shows LoadingError if error occurs');
  });

});
