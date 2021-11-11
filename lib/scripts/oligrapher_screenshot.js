#!/usr/bin/env node
const puppeteer = require('puppeteer')
const { argv, exit } = require('process')

async function screenshot(url) {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.goto(url)

  const svg = await page.evaluate( () => {
    window.Oligrapher.instance.hideAnnotations()
    return window.Oligrapher.instance.toSvg()
  })

  console.log(svg)

  await browser.close()
}

if (!argv[2] || !argv[2].includes('oligrapher')) {
  console.error("invalid url")
  exit(1)
}

screenshot(argv[2])
