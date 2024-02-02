/*
  These are simple actions that take a url and return information about the document.
  Urls are submitted in the request path and the server responds with json.

  To extract a title from a document:
  GET /title_extractor/https://littlesis.org
  returns {"title":"LittleSis - Profiling the powers that be"}

  Errors are return with status 400: { error }
*/
import * as http from 'http'
import extractTitle from './extractTitle.js'
import convertImage from './convertImage.js'

const port = process.env.LITTLESIS_JS_PORT ? Number(process.env.LITTLESIS_JS_PORT) : 8888
const host = process.env.LITTLESIS_JS_HOST ? process.env.LITTLESIS_JS_HOST : '127.0.0.1'

class RoutingError extends Error {
  constructor(route) {
    super(`No matching route: ${route}`)
  }
}

async function router(route, url) {
  switch(route) {
  case 'title_extractor':
    return { title: await extractTitle(url) }
  case 'dataurl':
    return { dataurl: await convertImage(url) }
  default:
    throw new RoutingError(route)
  }
}

const pathRegex = new RegExp('/(\\w+)/(.*)')

const listener = async function(req, res) {
  res.setHeader('Content-Type', 'application/json')

  try {
    const [route, url] = pathRegex.exec(req.url).slice(1,3)
    new URL(url) // raises error if not valid
    const body = JSON.stringify(await router(route, url))
    res.writeHead(200, { "Cache-Control": "max-age=14400, public" })
    res.end(body)
  } catch(e) {
    res.writeHead(400, { "Cache-Control": "max-age=60, public" })
    res.end(JSON.stringify({ error: e.message }))
  }
}

const server = http.createServer(listener).listen(port, host)

process.on('SIGTERM', async function() {
  await server.close()
  process.exit()
})
