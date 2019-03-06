import { retriveDatasetRow, retrivePotentialMatches } from './api_client';

const errorMessage = (label, err) => console.error(`[${label}]: `, err.message);

// ACTIONS
// these will take "updateState" or "setState" as the first argument

export function loadItemInfo(updateState, itemId) {
  updateState("itemInfoStatus", 'LOADING');

  retriveDatasetRow(itemId)
    .then(json => updateState({ "itemInfoStatus": 'COMPLETE', "itemInfo": json }))
    .catch(error => {
      errorMessage('loadItemInfo', error);
      updateState("itemInfoStatus", 'ERROR');
    });
};


export function loadMatches(updateState, itemId) {
  updateState("matchesStatus", 'LOADING');

  retrivePotentialMatches(itemId)
    .then(json => updateState({ "matchesStatus": 'COMPLETE', "matches": json }))
    .catch(error => {
      errorMessage('loadMatches', error);
      updateState("matchesStatus", 'ERROR');
    });
}
