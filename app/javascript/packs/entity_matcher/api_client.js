import isPlainObject from 'lodash/isPlainObject';
import isString from 'lodash/isString';

const jsonHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json"
};

const validateResponse = (res) => {
  if (res.status >= 200 && res.status < 300) { return res; }
  throw `response failed with status code: ${res.status}`;
};

/**
 * HTTP GET request to LittleSis Server
 * @param {String} url
 * @returns {Promise}
 */
export function lsFetch(url) {
  return fetch(url, {
    "credentials": 'same-origin',
    "headers": jsonHeaders
  })
    .then(validateResponse)
    .then(response => response.json());
}

/**
 * HTTP POST request to LittleSis Server
 * @param {String} url
 * @returns {Promise}
 */
export function lsPost(url, data) {
  var body;

  if (isString(data)) {
    body = data;
  } else if (isPlainObject(data)) {
    body = JSON.stringify(data);
  } else {
    throw "lsPost called with invalid data";
  }

  return fetch(url, {
    "method": "POST",
    "credentials": 'same-origin',
    "headers": jsonHeaders,
    "body": body
  })
    .then(validateResponse)
    .then(response => response.json());
}
