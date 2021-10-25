import { isString, isPlainObject, merge }  from 'lodash-es'

const jsonHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json"
};

const validateResponse = (res) => {
  if (res.status >= 200 && res.status < 300) { return res; }
  throw `response failed with status code: ${res.status}`;
};

/**
 * Converts object to query parameter string for HTTP get requests
 *
 * @param {String|Object} queryParams
 * @returns {String}
 */
export function qs(queryParams) {
  if (isString(queryParams) && queryParams.includes('=')) {
    return `?${queryParams}`;
  }

  if (isPlainObject(queryParams)) {
    let urlSearchParams = new URLSearchParams();

    for (var key in queryParams) {
      urlSearchParams.set(key, queryParams[key]);
    }

    return '?' + urlSearchParams.toString();
  }

  return '';
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

export const get = (url, params) => lsFetch(url + qs(params));

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

export default {
  lsFetch: lsFetch,
  get: get
};
