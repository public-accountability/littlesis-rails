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

export function matchRow(rowId, entityId) {
}
