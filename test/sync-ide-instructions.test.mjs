import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..');

const GENERATED_FROM_CURSOR =
  '<!-- Generated: .cursor/rules/agents-org.mdc. Run npm run sync:ide-instructions -->';

function makeTempRepo() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'org-ide-sync-'));
  fs.mkdirSync(path.join(dir, '.cursor', 'rules'), { recursive: true });
  fs.mkdirSync(path.join(dir, '.github'), { recursive: true });
  fs.mkdirSync(path.join(dir, 'scripts'), { recursive: true });
  fs.copyFileSync(
    path.join(REPO_ROOT, 'scripts', 'sync-ide-instructions.mjs'),
    path.join(dir, 'scripts', 'sync-ide-instructions.mjs'),
  );
  return dir;
}

function writeCanonical(repo, body) {
  const content = [
    '---',
    'description: Test org guidelines',
    'alwaysApply: true',
    '---',
    '',
    body,
    '',
  ].join('\n');
  fs.writeFileSync(path.join(repo, '.cursor', 'rules', 'agents-org.mdc'), content, 'utf-8');
}

function writePathRule(repo, filename, frontmatterLines, body) {
  const content = ['---', ...frontmatterLines, '---', '', body, ''].join('\n');
  fs.writeFileSync(path.join(repo, '.cursor', 'rules', filename), content, 'utf-8');
}

function trackRepo(repo) {
  tempRepos.push(repo);
  return repo;
}

async function runSync(repo, extraArgs = []) {
  await execFileAsync('node', ['scripts/sync-ide-instructions.mjs', ...extraArgs], { cwd: repo });
}

function readUtf8(repo, ...segments) {
  return fs.readFileSync(path.join(repo, ...segments), 'utf-8');
}

const tempRepos = [];

afterEach(() => {
  while (tempRepos.length > 0) {
    fs.rmSync(tempRepos.pop(), { recursive: true, force: true });
  }
});

describe('sync-ide-instructions', () => {
  it('writes copilot, claude, and codex mirrors from cursor source', async () => {
    const repo = trackRepo(makeTempRepo());
    writeCanonical(repo, '# Organization Guidelines\n\n## Validation\n');
    await runSync(repo);

    const copilotOutput = readUtf8(repo, '.github', 'copilot-instructions.md');
    assert.match(copilotOutput, /Generated: \.cursor\/rules\/agents-org\.mdc/);
    assert.match(copilotOutput, /# Organization Guidelines/);

    const claudeOutput = readUtf8(repo, 'CLAUDE.md');
    assert.ok(claudeOutput.includes(GENERATED_FROM_CURSOR));
    assert.doesNotMatch(claudeOutput, /alwaysApply: true/);
  });

  it('syncs path-scoped instructions from mdc with copilotInstructionsFile', async () => {
    const repo = trackRepo(makeTempRepo());
    writeCanonical(repo, '# Org\n');
    writePathRule(
      repo,
      'path-src.mdc',
      [
        'description: Use for src',
        'alwaysApply: false',
        'globs: src/**',
        'copilotInstructionsFile: src.instructions.md',
      ],
      '# Source path rule',
    );
    await runSync(repo);

    const instructions = readUtf8(repo, '.github', 'instructions', 'src.instructions.md');
    assert.match(instructions, /applyTo: "src\/\*\*"/);
    assert.match(instructions, /# Source path rule/);
  });

  it('quotes copilotApplyTo when emitting path-scoped instructions', async () => {
    const repo = trackRepo(makeTempRepo());
    writeCanonical(repo, '# Org\n');
    writePathRule(
      repo,
      'path-specs.mdc',
      [
        'description: Use for specs',
        'alwaysApply: false',
        'copilotApplyTo: specs/**',
        'copilotInstructionsFile: specs.instructions.md',
      ],
      '# Specs path rule',
    );
    await runSync(repo);

    const instructions = readUtf8(repo, '.github', 'instructions', 'specs.instructions.md');
    assert.match(instructions, /applyTo: "specs\/\*\*"/);
  });

  it('exits non-zero on drift when --check', async () => {
    const repo = trackRepo(makeTempRepo());
    writeCanonical(repo, '# Source\n');
    fs.writeFileSync(path.join(repo, '.github', 'copilot-instructions.md'), 'stale\n', 'utf-8');

    await assert.rejects(() => runSync(repo, ['--check']), (error) => error.code === 1);
  });
});
