/**
 * HTTP request to LittleSis Server
 * @param {String} url
 * @returns {Promise}
 */
export function lsFetch(url) {
  return fetch(url, {
    "credentials": 'same-origin',
    "headers": { "Content-Type": "application/json" }
  })
    .then(response => response.json());
}


/**
 * Retrives data JSON by id from the dataset
 * @param {Integer} id
 * @returns {Promise}
 */
export function retriveDatasetRow(id) {
  return lsFetch(`/external_datasets/row/${id}`);
}

export function retrivePotentialMatches(id) {
  return lsFetch(`/external_datasets/row/${id}/matches`);
}

export function matchRow(rowId, entityId) {
  // return lsFetch(`/external_datasets/row/${id}/match/${entityId}`));
}
