// import React from 'react';

import * as actions from 'packs/entity_matcher/actions';


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
