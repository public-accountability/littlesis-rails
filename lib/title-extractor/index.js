/*
  Urls are submitted as the request path
  server responds with extracted title from the document or return error message.

  Example GET http://title.extract/https://littlesis.org returns {"title":"LittleSis - Profiling the powers that be"}

  successful response: { title } status: 200
  error: { error } status: 400
 */

import * as http from 'http'
import * as cheerio from 'cheerio'
import fetch from 'node-fetch'

class HTTPResponseError extends Error {
  constructor(response, ...args) {
    super(`HTTP Error Response: ${response.status}`, ...args)
  }
}

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

const fetchUrl = async function(url) {
  const response = await fetch(url, { timeout: 10 })

  if (!response.ok) {
    throw new HTTPResponseError(response)
  }

  if (!response.headers.get('content-type').toLowerCase().includes('text/html')) {
    throw new ContentTypeIsNotHTMLError()
  }

  const body = await response.text()
  return cheerio.load(body)
}

const extractTitle = async function(url) {
  const $ = await fetchUrl(url)

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

const listener = async function(req, res) {
  res.setHeader('Content-Type', 'application/json')
  try {
    const url = req.url.slice(1)
    new URL(url) // raises error if not valid
    const title = await extractTitle(url)
    res.writeHead(200)
    res.end(JSON.stringify({ title: title }))
  } catch(e) {
    res.writeHead(400)
    res.end(JSON.stringify({ error: e.message }))
  }
}

const server = http.createServer(listener)

const port = process.env.TITLE_EXTRACTOR_PORT ? Number(process.env.TITLE_EXTRACTOR_PORT) : 8888

const host = process.env.TITLE_EXTRACTOR_HOST ? process.env.TITLE_EXTRACTOR_HOST : '127.0.0.1'

server.listen(port, host)
