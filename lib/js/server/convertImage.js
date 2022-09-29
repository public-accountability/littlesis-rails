import fetchUrl from './fetchUrl.js'
import { encode } from 'base64-arraybuffer'

class InvalidMediaTypeError extends Error {
  constructor(contentType) {
    super(`invalid media type ${contentType}`)
  }
}

// add image/webp ?
const validMediaTypes = new Set(['image/avif', 'image/gif', 'image/jpeg', 'image/png', 'image/svg+xml'])

export default async function(url) {
  const response = await fetchUrl(url)
  const contentType = response.headers.get('content-type').toLowerCase()

  if (!validMediaTypes.has(contentType)) {
    throw new InvalidMediaTypeError(contentType)
  }
  const buffer = await response.arrayBuffer()

  return "data:" + contentType + ';base64,' + encode(buffer)
}
