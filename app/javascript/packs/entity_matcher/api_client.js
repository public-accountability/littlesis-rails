import isPlainObject from 'lodash/isPlainObject';
import isString from 'lodash/isString';
import merge from 'lodash/merge';

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

  const token = document.head.querySelector('meta[name="csrf-token"]').content;
  const headers = merge(jsonHeaders, { 'X-CSRF-Token': token });
  
  // 'X-Requested-With': 'XMLHttpRequest',
  return fetch(url, {
    "method": "POST",
    "credentials": 'same-origin',
    "headers": headers,
    "body": body
  })
    .then(validateResponse)
    .then(response => response.json());
}
