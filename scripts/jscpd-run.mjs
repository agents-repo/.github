#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const CONFIG = path.join(REPO_ROOT, '.jscpd.json');

/**
 * @param {string[]} relativePaths paths relative to org hub repo root
 */
export function runJscpd(relativePaths) {
  const existing = relativePaths
    .map((segment) => path.resolve(REPO_ROOT, segment))
    .filter((absolute) => {
      if (fs.existsSync(absolute)) {
        return true;
      }
      console.warn(`jscpd: skipping missing path ${absolute}`);
      return false;
    });

  if (existing.length === 0) {
    console.error('jscpd: no paths to scan');
    process.exit(1);
  }

  const result = spawnSync(
    'npx',
    ['jscpd', '--config', CONFIG, ...existing],
    { cwd: REPO_ROOT, stdio: 'inherit', shell: false },
  );

  process.exit(result.status ?? 1);
}
