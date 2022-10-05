import fetch from 'node-fetch'

class HTTPResponseError extends Error {
  constructor(response, ...args) {
    super(`HTTP Error Response: ${response.status}`, ...args)
  }
}

export default async function(url) {
  const response = await fetch(url, { timeout: 10 })

  if (response.ok) {
    return response
  } else {
    throw new HTTPResponseError(response)
  }

}
