import { retriveDatasetRow } from './api_client';

// ACTIONS
// these will take "updateState" or "setState" as the first argument

export function loadItemInfo(updateState, itemId) {
  updateState("itemInfoStatus", 'LOADING');

  retriveDatasetRow(itemId)
    .then(json => updateState({ "itemInfoStatus": 'COMPLETE', "itemInfo": json }))
    .catch(error => {
      console.error('[loadItemInfo]: ', error.message);
      updateState("itemInfoStatus", 'ERROR');
    });
};
