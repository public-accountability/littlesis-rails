import clone from 'lodash/clone';
import curryRight from 'lodash/curryRight';
import filter from 'lodash/filter';
import toInteger from 'lodash/toInteger';
import merge from 'lodash/merge';

import { lsFetch } from './api_client';

const errorMessage = (label, err) => console.error(`[${label}]: `, err.message);

// ACTIONS
// These need to be "bound" to the component with the state...

export function loadItemInfo(itemId) {
  this.updateState("itemInfoStatus", 'LOADING');

  // retriveDatasetRow(itemId)
  lsFetch(`/external_datasets/row/${itemId}`)
    .then(json => this.updateState({ "itemInfoStatus": 'COMPLETE', "itemInfo": json }))
    .catch(error => {
      errorMessage('loadItemInfo', error);
      this.updateState("itemInfoStatus", 'ERROR');
    });
};


export function loadMatches(itemId) {
  this.updateState("matchesStatus", 'LOADING');

  lsFetch(`/external_datasets/row/${itemId}/matches`)
    .then(json => this.updateState({ "matchesStatus": 'COMPLETE', "matches": json }))
    .catch(error => {
      errorMessage('loadMatches', error);
      this.updateState("matchesStatus", 'ERROR');
    });
}

export function resultsWithoutEntity(results, entityId) {
  let isNotEntityPredicate = result => !(result.entity.id === toInteger(entityId));
  return filter(results, isNotEntityPredicate);
}

export function ignoreMatch(entityId) {
  this.setState((state, prop) => {
    let results = resultsWithoutEntity(state.matches.results, entityId);
    let matchesWithUpdatedResults = merge({}, state.matches, { "results": results });
    return { "matches": matchesWithUpdatedResults };
  });
}

export function matchRow(rowId, entityId) {
  this.updateState("matchesStatus", 'MATCHING');
}
