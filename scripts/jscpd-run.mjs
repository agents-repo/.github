#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const CONFIG = path.join(REPO_ROOT, '.jscpd.json');
const JSCPD_CLI = path.join(REPO_ROOT, 'node_modules', 'jscpd', 'run-jscpd.js');

function resolveJscpdInvocation() {
  if (!fs.existsSync(JSCPD_CLI)) {
    console.error('jscpd: install dependencies with npm ci in the org hub clone');
    process.exit(1);
  }
  return { executable: process.execPath, argsPrefix: [JSCPD_CLI] };
}

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

  const { executable, argsPrefix } = resolveJscpdInvocation();
  const result = spawnSync(executable, [...argsPrefix, '--config', CONFIG, ...existing], {
    cwd: REPO_ROOT,
    stdio: 'inherit',
    shell: false,
  });

  process.exit(result.status ?? 1);
}
