import * as cheerio from 'cheerio'
import fetchUrl from './fetchUrl.js'

class ContentTypeIsNotHTMLError extends Error {
  constructor(...args) {
    super("Content-Type is not HTML", ...args)
  }
}

class NoTitleFoundError extends Error {
  constructor(...args) {
    super("No Title Found", ...args)
  }
}

export default async function extractTitle(url) {
  const response = await fetchUrl(url)

  if (!response.headers.get('content-type').toLowerCase().includes('text/html')) {
    throw new ContentTypeIsNotHTMLError()
  }

  const body = await response.text()
  const $ = cheerio.load(body)

  var title = $('title').text()

  if (!title) {
    title = $('meta[property="og:title"]').attr('content')
  }

  if (!title) {
    title = $('h1').first().text()
  }

  if (title) {
    return title
  } else {
    throw new NoTitleFoundError()
  }
}
