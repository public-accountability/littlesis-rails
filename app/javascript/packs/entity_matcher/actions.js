import filter from 'lodash/filter';
import isNil from 'lodash/isNil';
import isNull from 'lodash/isNull';
import isPlainObject from 'lodash/isPlainObject';
import noop from 'lodash/noop';
import toInteger from 'lodash/toInteger';
import { Map } from 'immutable';
import { lsFetch, lsPost } from '../common/http';

const errorMessage = (label, err) => console.error(`[${label}]: `, err.message);

// ACTIONS
//
// All of these actions take the store as the first argument.
// If desired, you can bind that argument to make working with them easier:
//   actions.loadItemInfo.bind(undefined, store)

// action helpers

export const resultsWithoutEntity = (results, entityId) => {
  let isNotEntityPredicate = result => !(result.entity.id === toInteger(entityId));
  return filter(results, isNotEntityPredicate);
};  

export const defaultState = Map({
  "itemId": null, // item id (row id of External Dataset)
  "itemInfo": null, // json of external dataset attributes
  "itemInfoStatus": null, // status item info http request
  "matches": null, // Array of potential matches 
  "matchesStatus": null, // statues of potential matches http request
  "matchedState": null, // Has it been matched: MATCHING, MATCHED, ERROR
  "matchResult": null, // json response from matching
  "queue": null // options queue for items to match
});

// STATUS HELPERS
export const STATUS = Object.freeze({
  "LOADING": 'LOADING',
  "COMPLETE": 'COMPLETE',
  "ERROR": 'ERROR',
  "MATCHING": 'MATCHING',
  "MATCHED": 'MATCHED'
});

const resetStore = store => store.update(defaultState);

/// actions

const loadItemInfo = (store, itemId) => {
  store.update("itemInfoStatus", STATUS.LOADING);

  lsFetch(`/external_datasets/row/${itemId}`)
    .then(json => store.update({ "itemInfoStatus": STATUS.COMPLETE, "itemInfo": json }))
    .catch(error => {
      errorMessage('loadItemInfo', error);
      store.update("itemInfoStatus", STATUS.ERROR);
    });
};

const loadMatches = (store, itemId) => {
  store.update("matchesStatus", STATUS.LOADING);

  lsFetch(`/external_datasets/row/${itemId}/matches`)
    .then(json => store.update({ "matchesStatus": STATUS.COMPLETE, "matches": json }))
    .catch(error => {
      errorMessage('loadMatches', error);
      store.update("matchesStatus", STATUS.ERROR);
    });
};

const ignoreMatch = (store, entityId) => {
  store.update(state => state.mergeDeep({ matches: { results: resultsWithoutEntity(state.matches.results, entityId) } }))
};

const doMatch =  (store, rowId, entityOrId) => {
  store.update("matchedState", STATUS.MATCHING);

  let url = `/external_datasets/row/${rowId}/match`;

  let data = isPlainObject(entityOrId) ? { "entity": entityOrId } : { "entity_id": entityOrId };

  return lsPost(url, data)
    .then(json => store.update({ "matchedState": STATUS.MATCHED, "matchResult": json }))
    .catch(err => {
      errorMessage('doMatch', err);
      store.update("matchedState", STATUS.ERROR);
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

const nextItemFromQueue = store => {
  const currentIdx = store.get('queue').indexOf(store.get('itemId'));
  const itemHasBeenMatched = store.get("matchedState") === STATUS.MATCHED 

  let newState = {}
  let nextIdx;

  if (itemHasBeenMatched) {
    newState.queue = store.get('queue').delete(currentIdx)
    nextIdx = currentIdx
  } else {
    newState.queue = store.get('queue');
    nextIdx = currentIdx + 1;
  }

  if (newState.queue.isEmpty()) {
    newState.itemId = null
    return store.update(newState);
  }

  if (nextIdx >= newState.queue.size) {
    newState.itemId = newState.queue.get(0)
  } else {
    newState.itemId = newState.queue.get(nextIdx)
  }

  newState.itemInfoStatus = STATUS.LOADING;
  let callback = loadItemInfoAndMatches.bind(null, store);

  return store.update(newState, callback)
}

const nextItemFromUrl = store => {
  store.update("itemInfoStatus", STATUS.LOADING);
  let afterNextItemReceived = loadItemInfoAndMatches.bind(null, store);
  let updateItemId = json => store.update({ "itemId": json.next }, afterNextItemReceived);
  let url = store.globalProps.get('nextItemUrl');

  return lsFetch(url).then(updateItemId);
}

const nextItem = store => {
  resetStore(store);

  if (store.globalProps.get('flow') === 'queue') {
    return nextItemFromQueue(store);
  } else {
    return nextItemFromUrl(store);
  }
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
