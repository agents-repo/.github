#!/usr/bin/env node
/**
 * Build, preview, and drift-check Marp decks under docs/slides/.
 *
 * Usage:
 *   node scripts/slides.mjs build
 *   node scripts/slides.mjs preview
 *   node scripts/slides.mjs check
 */
import { createHash } from 'node:crypto'
import { spawnSync } from 'node:child_process'
import fs from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { Marp } from '@marp-team/marp-core'
import { marpCli } from '@marp-team/marp-cli'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const slidesDir = path.join(root, 'docs', 'slides')
const themeDir = path.join(slidesDir, 'theme')
const themeCssPath = path.join(themeDir, 'theme.css')
const pdfDir = path.join(slidesDir, 'pdf')
const buildDir = path.join(slidesDir, 'build')

const command = process.argv[2]

if (!['build', 'preview', 'check'].includes(command)) {
  console.error('Usage: node scripts/slides.mjs <build|preview|check>')
  process.exit(2)
}

async function listDecks() {
  const entries = await fs.readdir(slidesDir)
  return entries
    .filter((name) => name.endsWith('.md') && name !== 'README.md')
    .sort()
    .map((name) => ({
      stem: name.slice(0, -'.md'.length),
      source: path.join(slidesDir, name)
    }))
}

function chromeCandidates() {
  const fromEnv = [
    process.env.PUPPETEER_EXECUTABLE_PATH,
    process.env.CHROME_PATH
  ].filter(Boolean)

  const whichBins = [
    'google-chrome',
    'google-chrome-stable',
    'chromium',
    'chromium-browser',
    'chrome'
  ]
    .map((bin) => {
      const result = spawnSync('which', [bin], { encoding: 'utf8' })
      return result.status === 0 ? result.stdout.trim() : ''
    })
    .filter(Boolean)

  const macPaths = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium'
  ]

  return [...fromEnv, ...whichBins, ...macPaths]
}

async function resolveBrowserPath() {
  for (const candidate of chromeCandidates()) {
    try {
      await fs.access(candidate)
      return candidate
    } catch {
      // try next
    }
  }
  return undefined
}

async function fingerprintDeck(sourcePath, themeCss) {
  const markdown = await fs.readFile(sourcePath, 'utf8')
  const marp = new Marp({ html: true })
  marp.themeSet.add(themeCss)
  const { html, css } = marp.render(markdown)
  return createHash('sha256').update(html).update('\n').update(css).digest('hex')
}

function hashPath(stem) {
  return path.join(pdfDir, `${stem}.src.sha256`)
}

async function runMarp(args) {
  const exitCode = await marpCli(args)
  if (exitCode !== 0) {
    throw new Error(`marp-cli exited with code ${exitCode}`)
  }
}

async function convertDeck(deck, outputPath, extraArgs) {
  const browserPath = await resolveBrowserPath()
  const args = [
    deck.source,
    '--allow-local-files',
    '--theme-set',
    themeDir,
    '--output',
    outputPath,
    ...extraArgs
  ]
  if (browserPath) {
    args.push('--browser-path', browserPath)
  }
  await runMarp(args)
}

async function buildPdfs() {
  const decks = await listDecks()
  if (decks.length === 0) {
    throw new Error(`No Marp decks found in ${slidesDir}`)
  }
  const themeCss = await fs.readFile(themeCssPath, 'utf8')
  await fs.mkdir(pdfDir, { recursive: true })
  for (const deck of decks) {
    const pdfPath = path.join(pdfDir, `${deck.stem}.pdf`)
    await convertDeck(deck, pdfPath, ['--pdf'])
    const digest = await fingerprintDeck(deck.source, themeCss)
    await fs.writeFile(hashPath(deck.stem), `${digest}\n`, 'utf8')
    console.log(`Wrote ${path.relative(root, pdfPath)}`)
  }
}

async function previewHtml() {
  const decks = await listDecks()
  if (decks.length === 0) {
    throw new Error(`No Marp decks found in ${slidesDir}`)
  }
  await fs.mkdir(buildDir, { recursive: true })
  for (const deck of decks) {
    const htmlPath = path.join(buildDir, `${deck.stem}.html`)
    await convertDeck(deck, htmlPath, ['--html'])
    console.log(`Wrote ${path.relative(root, htmlPath)}`)
  }
}

async function checkDecks() {
  const decks = await listDecks()
  if (decks.length === 0) {
    throw new Error(`No Marp decks found in ${slidesDir}`)
  }
  const themeCss = await fs.readFile(themeCssPath, 'utf8')
  const failures = []

  for (const deck of decks) {
    const pdfPath = path.join(pdfDir, `${deck.stem}.pdf`)
    try {
      const stat = await fs.stat(pdfPath)
      if (stat.size < 1024) {
        failures.push(`${deck.stem}: committed PDF is too small (${stat.size} bytes)`)
      }
    } catch {
      failures.push(`${deck.stem}: missing ${path.relative(root, pdfPath)}`)
    }

    const digest = await fingerprintDeck(deck.source, themeCss)
    let recorded = ''
    try {
      recorded = (await fs.readFile(hashPath(deck.stem), 'utf8')).trim()
    } catch {
      failures.push(
        `${deck.stem}: missing source fingerprint ${path.relative(root, hashPath(deck.stem))}`
      )
      continue
    }
    if (recorded !== digest) {
      failures.push(
        `${deck.stem}: source drifted from committed PDF fingerprint (run npm run slides:build)`
      )
    }
  }

  const browserPath = await resolveBrowserPath()
  if (!browserPath) {
    failures.push(
      'Chromium/Chrome not found. Set PUPPETEER_EXECUTABLE_PATH or CHROME_PATH, or install Chrome.'
    )
  } else {
    const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'agents-repo-slides-check-'))
    try {
      for (const deck of decks) {
        const tmpPdf = path.join(tmpDir, `${deck.stem}.pdf`)
        await convertDeck(deck, tmpPdf, ['--pdf'])
        const stat = await fs.stat(tmpPdf)
        if (stat.size < 1024) {
          failures.push(`${deck.stem}: rebuilt PDF is too small (${stat.size} bytes)`)
        }
      }
    } finally {
      await fs.rm(tmpDir, { recursive: true, force: true })
    }
  }

  if (failures.length > 0) {
    console.error(failures.join('\n'))
    process.exit(1)
  }
  console.log(`slides:check passed for ${decks.length} deck(s)`)
}

try {
  if (command === 'build') {
    await buildPdfs()
  } else if (command === 'preview') {
    await previewHtml()
  } else {
    await checkDecks()
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : error)
  process.exit(1)
}
