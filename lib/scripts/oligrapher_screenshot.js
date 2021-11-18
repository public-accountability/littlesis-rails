#!/usr/bin/env node
const { argv, exit } = require('process')
const path = require('path')
const puppeteer = require('puppeteer')
//const sharp = require('sharp')

// String --> Promise<String>
async function screenshot(url) {
  const id = url.match(/.*oligrapher\/(\d+).*/)[1]
  const filepath = path.join(__dirname, '../../public/images/oligrapher/', `${id}.png`)

  const browser = await puppeteer.launch(
    { "viewport": { "width":  1280, "height": 1024 } }
  )
  const page = await browser.newPage()
  await page.goto(url, { "waitUntil": 'networkidle0' })
  await page.waitForSelector('#oligrapher-svg')

  await page.evaluate( () => {
    window.Oligrapher.instance.hideAnnotations()
    window.Oligrapher.instance.hideHeader()
    window.Oligrapher.instance.hideZoomControl()
  })

  const element = await page.$('#oligrapher-svg')
  await element.screenshot({ path: filepath })
  await browser.close()
}

// Promise, Number --> Promise
function timeout(promise, time) {
  return Promise.race(
    [promise, new Promise((resolve, reject) => setTimeout(() => reject('timeout'), time)) ]
  )
}

const url = argv[2]

if (!url || !url.includes('oligrapher')) {
  console.error("invalid url")
  exit(1)
}

timeout(screenshot(url), 30000)
  .then(() => exit(0))
  .catch(err => {
    console.error(err)
    exit(1)
  })
