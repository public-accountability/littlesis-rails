// import React from 'react';

import * as actions from 'packs/entity_matcher/actions';

beforeEach(() => fetch.resetMocks());

describe('resultsWithoutEntity', () => {
  const results = [
    { "entity": { "id": 1, name: 'one'} },
    { "entity": { "id": 2, name: 'two'} },
    { "entity": { "id": 3, name: 'three'} }
  ];

  test('It removes entity with 2 from array', () => {
    expect(actions.resultsWithoutEntity(results, 2))
      .toEqual([
	{ "entity": { "id": 1, name: 'one'} },
	{ "entity": { "id": 3, name: 'three'} }
      ]);
  });

});

describe('doMatch', () => {
  const mockMatchResponse = { "status": 'OK',
			      "results": ['owner_not_matched'],
			      "entity": { id: 123, name: 'abc' } };
  
  beforeEach(function() {
    document.head.innerHTML = '<meta name="csrf-token" content="abcd">';
    fetch.mockResponseOnce(JSON.stringify(mockMatchResponse));
  });

  test('updates matches before and after request', async () => {
    let mockBindingObject = { "updateState": jest.fn() };
    await actions.doMatch.call(mockBindingObject, 123, 456);

    expect(fetch.mock.calls[0][0]).toEqual('/external_datasets/row/123/match');
    expect(fetch.mock.calls[0][1].body).toEqual(JSON.stringify({entity_id: 456}));
    expect(mockBindingObject.updateState.mock.calls.length).toEqual(2);
    expect(mockBindingObject.updateState.mock.calls[0]).toEqual(['matchedState', 'MATCHING']);
    expect(mockBindingObject.updateState.mock.calls[1]).toEqual([ {
      "matchedState": 'MATCHED',
      "matchResult": mockMatchResponse
    }]);
  });

  test('set post data when given entity object', async () => {
    let mockBindingObject = { "updateState": jest.fn() };
    let entityObj = { name: 'test', blurb: 'test blurb', primary_ext: 'Org' };
    await actions.doMatch.call(mockBindingObject, 123, entityObj);

    expect(fetch.mock.calls[0][0]).toEqual('/external_datasets/row/123/match');
    expect(fetch.mock.calls[0][1].body).toEqual(JSON.stringify({entity: entityObj}));
  });
});
