import filter from 'lodash/filter';
import toInteger from 'lodash/toInteger';
import merge from 'lodash/merge';

import { lsFetch, lsPost } from './api_client';

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

export function doMatch(rowId, entityId) {
  this.updateState("matchStatus", 'MATCHING');

  let url = `/external_datasets/row/${rowId}/match`;
  let data = {"entity_id": entityId };

  return lsPost(url, data)
    .then(() => this.updateState("matchStatus", 'MATCHED'))
    .catch(err => {
      console.error(`Failed to match row ${rowId} with entity ${entityId}`);
      errorMessage('doMatch', err);
      this.updateState("matchStatus", 'ERROR');
    });

}

export function nextItem() {
  this.resetState();
  this.updateState("itemInfoStatus", 'LOADING');

  let url = `/external_datasets/${this.props.dataset}/flow/${this.props.flow}/next`;
  
  lsFetch(url)
    .then( json => this.setState({ "itemId": json.next}, this.loadItemInfoAndMatches));
}
