#!/usr/bin/env node
const puppeteer = require('puppeteer')
const { argv, exit } = require('process')

async function screenshot(url) {
  const browser = await puppeteer.launch(
    { "viewport": { "width":  1280, "height": 1024 } }
  )
  const page = await browser.newPage()
  await page.goto(url)
  await page.waitForSelector('#oligrapher-svg')

  const svg = await page.evaluate( () => {
    window.Oligrapher.instance.hideAnnotations()
    return window.Oligrapher.instance.toSvg()
  })

  await browser.close()

  return svg
}

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
  .then(svg => {
    console.log(svg)
    exit(0)
  })
  .catch(err => {
    console.error(err)
    exit(1)
  })
