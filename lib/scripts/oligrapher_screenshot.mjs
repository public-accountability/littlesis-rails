#!/usr/bin/env node

import { argv, exit } from "node:process"
import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"
import puppeteer from "puppeteer"
import sharp from "sharp"

const image_dir = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "../../public/images/oligrapher"
)

const url = argv[2]

if (!url || !url.includes("oligrapher")) {
  console.error("invalid url")
  exit(1)
}

timeout(screenshot(url), 30000)
  .then(createVariations)
  .then(() => exit(0))
  .catch(err => {
    console.error(err)
    exit(1)
  })

// saves oligrapher screenshot as svg and returns filepath under public/images/oligrapher
// (url: string) => Promise<string>
async function screenshot(url) {
  const id = url.match(/.*oligrapher\/(\d+).*/)[1]
  const filepath = path.join(image_dir, `${id}.svg`)
  const browser = await puppeteer.launch({
    viewport: { width: 1280, height: 1024 },
    args: ["--window-size=1280,1024"],
  })
  const page = await browser.newPage()
  await page.goto(url, { waitUntil: "domcontentloaded" })

  await page.waitForSelector("#oligrapher-container")

  const svg = await page.evaluate(() => {
    return window.Oligrapher.instance.toSvg()
  })

  fs.writeFileSync(filepath, svg)
  await browser.close()
  return filepath
}

// Creates png, avif, jpeg files
async function createVariations(filepath) {
  if (!fs.existsSync(filepath)) {
    throw new Error(`${filepath} does not exist`)
  }

  return Promise.all([
    sharp(filepath)
      .toFormat("jpeg")
      .jpeg({ mozjpeg: true })
      .toFile(filepath.replace("svg", "jpeg")),
    sharp(filepath).avif().toFile(filepath.replace("svg", "avif")),
    sharp(filepath).png().toFile(filepath.replace("svg", "png")),
    sharp(filepath)
      .resize({ width: 300 })
      .toFormat("jpeg")
      .jpeg({ mozjpeg: true })
      .toFile(filepath.replace(".svg", ".small.jpeg")),
  ])
}

function timeout(promise, time) {
  return Promise.race([
    promise,
    new Promise((resolve, reject) => setTimeout(() => reject("timeout"), time)),
  ])
}
