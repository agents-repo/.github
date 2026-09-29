import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';

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

const tempRepos = [];

afterEach(() => {
  while (tempRepos.length > 0) {
    fs.rmSync(tempRepos.pop(), { recursive: true, force: true });
  }
});

describe('sync-ide-instructions', () => {
  it('writes copilot, claude, and codex mirrors from cursor source', async () => {
    const repo = makeTempRepo();
    tempRepos.push(repo);
    writeCanonical(repo, '# Organization Guidelines\n\n## Validation\n');

    const { execFile } = await import('node:child_process');
    const { promisify } = await import('node:util');
    const execFileAsync = promisify(execFile);
    await execFileAsync('node', ['scripts/sync-ide-instructions.mjs'], { cwd: repo });

    const copilotOutput = fs.readFileSync(
      path.join(repo, '.github', 'copilot-instructions.md'),
      'utf-8',
    );
    assert.match(copilotOutput, /Generated: \.cursor\/rules\/agents-org\.mdc/);
    assert.match(copilotOutput, /# Organization Guidelines/);

    const claudeOutput = fs.readFileSync(path.join(repo, 'CLAUDE.md'), 'utf-8');
    assert.ok(claudeOutput.includes(GENERATED_FROM_CURSOR));
    assert.doesNotMatch(claudeOutput, /alwaysApply: true/);
  });

  it('syncs path-scoped instructions from mdc with copilotInstructionsFile', async () => {
    const repo = makeTempRepo();
    tempRepos.push(repo);
    writeCanonical(repo, '# Org\n');
    const pathMdc = [
      '---',
      'description: Use for src',
      'alwaysApply: false',
      'globs: src/**',
      'copilotInstructionsFile: src.instructions.md',
      '---',
      '',
      '# Source path rule',
      '',
    ].join('\n');
    fs.writeFileSync(path.join(repo, '.cursor', 'rules', 'path-src.mdc'), pathMdc, 'utf-8');

    const { execFile } = await import('node:child_process');
    const { promisify } = await import('node:util');
    const execFileAsync = promisify(execFile);
    await execFileAsync('node', ['scripts/sync-ide-instructions.mjs'], { cwd: repo });

    const instructions = fs.readFileSync(
      path.join(repo, '.github', 'instructions', 'src.instructions.md'),
      'utf-8',
    );
    assert.match(instructions, /applyTo: "src\/\*\*"/);
    assert.match(instructions, /# Source path rule/);
  });

  it('exits non-zero on drift when --check', async () => {
    const repo = makeTempRepo();
    tempRepos.push(repo);
    writeCanonical(repo, '# Source\n');
    fs.writeFileSync(path.join(repo, '.github', 'copilot-instructions.md'), 'stale\n', 'utf-8');

    const { execFile } = await import('node:child_process');
    const { promisify } = await import('node:util');
    const execFileAsync = promisify(execFile);
    await assert.rejects(
      () => execFileAsync('node', ['scripts/sync-ide-instructions.mjs', '--check'], { cwd: repo }),
      (error) => error.code === 1,
    );
  });
});
