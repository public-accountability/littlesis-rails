import curry from 'lodash/curry';
import filter from 'lodash/filter';
import toInteger from 'lodash/toInteger';
import isPlainObject from 'lodash/isPlainObject';
import isNull from 'lodash/isNull';
import merge from 'lodash/merge';
import { Map } from 'immutable';

import { lsFetch, lsPost } from '../common/http';

const errorMessage = (label, err) => console.error(`[${label}]: `, err.message);

// ACTIONS
//
// All of these actions take the store as the first argument.
// If desired, you can bind that argument to make working with them easier:
//   actions.loadItemInfo.bind(undefined, store)

// action helpers

const resultsWithoutEntity = (results, entityId) => {
  let isNotEntityPredicate = result => !(result.entity.id === toInteger(entityId));
  return filter(results, isNotEntityPredicate);
};  

const defaultState = Map({
  "itemId": null, // item id (row id of External Dataset)
  "itemInfo": null, // json of external dataset attributes
  "itemInfoStatus": null, // status item info http request
  "matches": null, // Array of potential matches 
  "matchesStatus": null, // statues of potential matches http request
  "matchedState": null, // Has it been matched: MATCHING, MATCHED, ERROR
  "matchResult": null, // json response from matching
  "nextItemQueue": null // options queue for items to match
});

const resetStore = store => store.update(defaultState);

/// actions

const loadItemInfo = (store, itemId) => {
  store.update("itemInfoStatus", 'LOADING');

  lsFetch(`/external_datasets/row/${itemId}`)
    .then(json => store.update({ "itemInfoStatus": 'COMPLETE', "itemInfo": json }))
    .catch(error => {
      errorMessage('loadItemInfo', error);
      store.update("itemInfoStatus", 'ERROR');
    });
};

const loadMatches = (store, itemId) => {
  store.update("matchesStatus", 'LOADING');

  lsFetch(`/external_datasets/row/${itemId}/matches`)
    .then(json => store.update({ "matchesStatus": 'COMPLETE', "matches": json }))
    .catch(error => {
      errorMessage('loadMatches', error);
      store.update("matchesStatus", 'ERROR');
    });
};

const ignoreMatch = (store, entityId) => {
  store.update(state => state.mergeDeep({ matches: { results: resultsWithoutEntity(state.matches.results, entityId) } }))
};

const doMatch =  (store, rowId, entityOrId) => {
  store.update("matchedState", 'MATCHING');

  let url = `/external_datasets/row/${rowId}/match`;

  let data = isPlainObject(entityOrId) ? { "entity": entityOrId } : { "entity_id": entityOrId };

  return lsPost(url, data)
    .then(json => store.update({ "matchedState": 'MATCHED', "matchResult": json }))
    .catch(err => {
      errorMessage('doMatch', err);
      store.update("matchedState", 'ERROR');
    });

};

const loadItemInfoAndMatches = (store) => {
  let itemId = store.get('itemId');
  
  if (!store.get('itemInfo')) {
    loadItemInfo(store, itemId)
  }

  if (isNull(store.get('matchesStatus'))) {
    loadMatches(store, itemId);
  }
};

const nextItem = (store) => {
  resetStore(store);
  store.update("itemInfoStatus", 'LOADING');
  let afterNextItemReceived = loadItemInfoAndMatches.bind(null, store);
  let updateItemId = json => store.update({ "itemId": json.next }, afterNextItemReceived);
  let url = store.globalProps.get('nextItemUrl');

  return lsFetch(url).then(updateItemId);
}

const actions = {
  "withStore": function(store) {
    let actionsWithStore = {};
      
    for (let key in this) {
      if (key !== 'withStore') {
	actionsWithStore[key] = this[key].bind(actionsWithStore, store);
      }
    }

    return actionsWithStore;
  },

  "loadItemInfo": loadItemInfo,
  "loadMatches": loadMatches,
  "ignoreMatch": ignoreMatch,
  "doMatch": doMatch,
  "loadItemInfoAndMatches": loadItemInfoAndMatches,
  "nextItem": nextItem
}

export default actions;
