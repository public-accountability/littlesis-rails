import { isString, isPlainObject, merge }  from 'lodash-es'

class RequestFailureError extends Error {
  constructor(status) {
    super(`response failed with status code: ${status}`)
    this.name = "RequestFailureError"
    this.status = status
  }
}

const jsonHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json"
}

const validateResponse = (res) => {
  if (res.status >= 200 && res.status < 300) {
    return res
  }
  throw new RequestFailureError(res.status)
}

// String | Object | Any --> String
export function qs(queryParams) {
  if (isString(queryParams) && queryParams.includes('=')) {
    return `?${queryParams}`
  }
  if (isPlainObject(queryParams)) {
    let urlSearchParams = new URLSearchParams()

    for (var key in queryParams) {
      urlSearchParams.set(key, queryParams[key])
    }

    return '?' + urlSearchParams.toString()
  }

  return ''
}

// String, (String, Object, Nil) --> Promise<Json>
export function get(url, params) {
  return fetch(url + qs(params), {
    "credentials": 'same-origin',
    "headers": jsonHeaders
  })
    .then(validateResponse)
    .then(response => response.json())
}

// String, Object, Options --> Promise<Json>
export function post(url, data, options = {}) {
  if (!isPlainObject(data)) {
    throw "Post called with invalid data"
  }

  const body = JSON.stringify(data)
  const token = document.head.querySelector('meta[name="csrf-token"]')?.content
  const headers = merge({}, jsonHeaders, { 'X-CSRF-Token': token })

  return fetch(url, {
    "method": (options.patch ? "PATCH" : "POST"),
    "credentials": 'same-origin',
    "headers": headers,
    "body": body
  })
    .then(validateResponse)
    .then(response => response.json());
}

export function patch(url, data) {
  return post(url, data, { patch: true })
}

export default {
  get: get,
  post: post,
  patch: patch
}
